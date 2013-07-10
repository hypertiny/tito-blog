---
layout: post
title:  "An eCommerce Refactor: Cleaning up a Common Pattern in a Rails eCommerce App"
date:   2012-10-18
author: Paul Campbell
readingtime: 6
tags: [code]
---

“We can’t add any more features”, I said to Cillian. We had reached that point when building a web app using Rails that if we added another line to that controller, I couldn’t help but feel the whole thing would come crashing down, like placing the last block in a game of Jenga.

“We need to refactor.”

The code in question was extremely common code: handling customer payments.

Like many, many eCommerce setups out there, we wanted to be able to accept payment by PayPal, or by credit card. Since we also wanted to support multiple stores, we wanted to accept multiple payment gateways.

The purchase controller logic looked a bit like this:

{% highlight ruby linenos %}
  class PurchasesController
    def create
      @purchase = Purchase.new(params[:purchase])
   
      if @purchase.free?
        if @purchase.confirm
          redirect_to @purchase
        else
          render :new
        end
      else
        if @purchase.paypal?
          redirect_to_paypal
        elsif @purchase.credit_card?
          if purchase_attempt = @purchase.confirm && purchase_attempt.success?
            redirect_to @purchase
          else
            render :new
          end
        end
      end
    end
  end
{% endhighlight %}

This is a simplification of the actual spaghetti code, but it serves to illustrate a few points that I want to highlight.

For me, it all starts with the unfortunate use of the word “Purchase”. Purchase is a noun that’s very much connected to a verb: the action of buying. In eCommerce terms, a purchase is actually quite a complex interaction: choosing what to buy, agreeing to do it, agreeing on a payment type, making that payment and then receiving the goods.

Take a look at the relevant methods in that `Purchase` model:

{% highlight ruby linenos %}
  class Purchase
   
    def confirm_free
      complete_order
    end
   
    def confirm_paypal
      if paypal_transaction.success?
        complete_order
      end
    end
   
    def confirm_credit_card
      if credit_card_transaction.success?
        complete_order
      end
    end
   
    def confirm
      case
      when free?
        confirm_free
      when paypal?
        confirm_paypal
      when credit_card?
        confirm_credit_card
      end
    end
   
    def complete_order
      create_receipt
      confirm_purchase
      send_order_email
      set_as_complete
    end
  end
{% endhighlight %}

I’ve tried to simplify the sample code, but you can see that there’s already quite a lot going on. Ultimately, naming the model `Purchase` led to giving too much responsibility to that class. Here are the steps the logic has to take:

1. Decide if the purchase is free, PayPal or credit card
2. Verify the transaction in each case
3. Create a receipt for the payment
4. Complete the order

The key realisation for me was in those steps 3 and 4. There was a bunch of behavior around the `Payment` and a bunch of behavior around the `Order`. In fact, the behavior relating to the order didn’t seem to have anything to do with the payment and the payment behavior didn’t really have anything to do with what the customer was purchasing, other than the price and some shipping logic.

Going back up to the controller, it feels like it’s obvious now too: there’s too much domain logic in there. The controller shouldn’t care about things like “free?” and “paypal?” and “credit_card?”. The controller is concerned about input and output: taking action as a result of domain logic: the logic itself should be elsewhere.

Here’s what I decided to do:

1. Split `Purchase` into `Order` and `Payment`, separating the logic
2. Implement a controller for each
3. Separate classes for each payment type conforming to a common API

Here’s how the controllers ended up:

{% highlight ruby linenos %}
  class OrdersController
    def create
      @order = Order.new(params[:order])
      if @order.paid?
        if @order.payment.redirect?
          redirect_to @order.redirect_url
        else
          redirect_to [@order, @payment]
        end
      else
        if @order.complete
          redirect_to @order
        else
          render :new
        end
      end
    end
  end
   
  class PaymentsController
    def create
      @order = @order.find(params[:order_id])
      @payment = @order.payment
      if @payment.redirect?
        redirect_to @payment.redirect_url
      else
        if @payment.confirm(params[:payment])
          redirect_to @order
        else
          render :edit
        end
      end
    end
  end
{% endhighlight %}

Now the controllers don’t care about PayPal, don’t care about credit card. The `Order` model implements the `Order#paid?` method, and if an order is paid, it should have a payment attached to it, which either redirects or it doesn’t.

Similarly, the payments controller asks the `Payment` object what to do.

What’s neat about this is that the controller doesn’t have to change, and the underlying models do all of the work. We can use Rails’s STI implementation to create multiple classes that implement the simple API that the controller uses.

Here’s how the underlying model structure ended up:

{% highlight ruby linenos %}
  class Payment
    # common payment functionality here
  end
   
  class Payment::CreditCard
    validates_as_credit_card
   
    def confirm(attrs)
      if update_attributes(attrs)
        if authorized? || authorize
          order.complete
        end
      end
    end
  end
   
  class Payment::CreditCard::SampleProvider
    def redirect?
      false
    end
   
    def authorize
      return if authorized?
      transaction do
        if SampleProviderApi.authorize(price)
          update_column(:authorized, true)
        end
      end
    end
  end
   
  class Payment::PayPal
    include PayPalGateway
   
    def redirect?
      true
    end
   
    def redirect_url
      paypal_gateway.redirect_url
    end
  end
   
  class Order
    def complete
      send_order_email
      set_as_complete
    end
  end
{% endhighlight %}

This new structure does a few things.

First, it removes business logic from the controller. The controller is still making decisions based on the state of the objects it’s interacting with, but the questions are at a higher level, and the results deal with dispatching behaviour, rather than making business decisions.

Second, the controller logic is consistent accross all implementations of the Payment model. It doesn’t care whether the underlying payment is PayPal or a credit card API. It just calls a common API that the underlying models implement.

Third, the domain is split up into logical concerns. The Order model now no longer cares about anything to do with accepting payment. If the order is not free, it has an attached payment option that handles these concerns.

Finally, the Payment model handles common payment logic, with its sub-classes implementing the particulars for each underlying API.

Of course, these changes assume a solid set of tests which were in place before this refactoring. Further: the refactoring makes it easier to test each component in isolation in our unit tests.

The actual refactoring described here took about a month to do, between testing various formations and moving huge chunks of code about. I consider it a month well spent.

Technical debt accrues as you rush to ship a release, to get a new feature out or just in the every day beat of adding features on top of existing functionality.

This refactor paid off a bit of this debt, and gave us space. Space not only in the smaller classes that do less, but more specific work, but also headspace: peace of mind knowing that the app is tidier, simpler, easier to understand and, ultimately, easier to change.

“Ok, what should we do now?” I asked Cillian.

“Let’s add that feature that everyone’s been looking for.”

