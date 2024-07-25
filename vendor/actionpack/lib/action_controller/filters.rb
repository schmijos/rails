module ActionController #:nodoc:
  module Filters #:nodoc:
    def self.append_features(base)
      super
      base.extend(ClassMethods)
      base.class_eval { include ActionController::Filters::InstanceMethods }
    end

    # Filters enable controllers to run shared pre and post processing code for its actions. These filters can be used to do 
    # authentication, caching, or auditing before the intended action is performed. Or to do localization or output 
    # compression after the action has been performed.
    #
    # Filters have access to the request, response, and all the instance variables set by other filters in the chain
    # or by the action (in the case of after filters). Additionally, it's possible for a pre-processing <tt>before_filter</tt>
    # to halt the processing before the intended action is processed by returning false. This is especially useful for
    # filters like authentication where you're not interested in allowing the action to be performed if the proper 
    # credentials are not in order.
    #
    # == Filter inheritance
    #
    # Controller inheritance hierarchies share filters downwards, but subclasses can also add new filters without
    # affecting the superclass. For example:
    #
    #   class BankController < ActionController::Base
    #     before_filter :audit
    #
    #     private
    #       def audit
    #         # record the action and parameters in an audit log
    #       end
    #   end
    #
    #   class VaultController < BankController
    #     before_filter :verify_credentials
    #
    #     private
    #       def verify_credentials
    #         # make sure the user is allowed into the vault
    #       end
    #   end
    #
    # Now any actions performed on the BankController will have the audit method called before. On the VaultController,
    # first the audit method is called, then the verify_credentials method. If the audit method returns false, then 
    # verify_credentials and the intended action is never called.
    #
    # == Filter types
    #
    # A filter can take one of three forms: method reference (symbol), external class, or inline method (proc). The first
    # is the most common and works by referencing a protected or private method somewhere in the inheritance hierarchy of
    # the controller by use of a symbol. In the bank example above, both BankController and VaultController uses this form.
    #
    # Using an external class makes for more easily reused generic filters, such as output compression. External filter classes
    # are implemented by having a static +filter+ method on any class and then passing this class to the filter method. Example:
    #
    #   class OutputCompressionFilter
    #     def self.filter(controller)
    #       controller.response.body = compress(controller.response.body)
    #     end
    #   end
    #
    #   class NewspaperController < ActionController::Base
    #     after_filter OutputCompressionFilter
    #   end
    #
    # The filter method is passed the controller instance and is hence granted access to all aspects of the controller and can
    # manipulate them as it sees fit.
    #
    # The inline method (using a proc) can be used to quickly do something small that doesn't require a lot of explanation. 
    # Or just as a quick test. It works like this:
    #
    #   class WeblogController < ActionController::Base
    #     before_filter proc{ |controller| return false if controller.params["stop_action"] }
    #   end
    #
    # As you can see, the proc expects to be passed the controller after it has assigned the request to the internal variables.
    # This means that the proc has access to both the request and response objects complete with convenience methods for params,
    # session, template, and assigns. Note: The inline method doesn't strictly has to be a Proc. Any object that responds to call
    # and returns 1 or -1 on arity will do (such as a Method object).
    #
    # == Filter chain ordering
    #
    # Using <tt>before_filter</tt> and <tt>after_filter</tt> appends the specified filters to the existing chain. That's usually
    # just fine, but some times you care more about the order in which the filters are executed. When that's the case, you
    # can use <tt>prepend_before_filter</tt> and <tt>prepend_after_filter</tt>. Filters added by these methods will be put at the
    # beginning of their respective chain and executed before the rest. For example:
    #
    #   class ShoppingController
    #     before_filter :verify_open_shop
    #
    #   class CheckoutController
    #     prepend_before_filter :ensure_items_in_cart, :ensure_items_in_stock
    #
    # The filter chain for the CheckoutController is now <tt>:ensure_items_in_cart, :ensure_items_in_stock,</tt>
    # <tt>:verify_open_shop</tt>. So if either of the ensure filters return false, we'll never get around to see if the shop 
    # is open or not.
    module ClassMethods
      # The passed <tt>filters</tt> will be appended to the array of filters that's run _before_ actions
      # on this controller are performed.
      def append_before_filter(*filters)  append_filter("before", filters) end

      # The passed <tt>filters</tt> will be prepended to the array of filters that's run _before_ actions
      # on this controller are performed.
      def prepend_before_filter(*filters) prepend_filter("before", filters) end

      # Short-hand for append_before_filter since that's the most common of the two.
      alias :before_filter :append_before_filter
      
      # The passed <tt>filters</tt> will be appended to the array of filters that's run _after_ actions
      # on this controller are performed.
      def append_after_filter(*filters)  append_filter("after", filters) end

      # The passed <tt>filters</tt> will be prepended to the array of filters that's run _after_ actions
      # on this controller are performed.
      def prepend_after_filter(*filters) prepend_filter("after", filters) end

      # Short-hand for append_after_filter since that's the most common of the two.
      alias :after_filter :append_after_filter
      
      # Returns all the before filters for this class and all its ancestors.
      def before_filters #:nodoc:
        read_inheritable_attribute("before_filters")
      end
      
      # Returns all the after filters for this class and all its ancestors.
      def after_filters #:nodoc:
        read_inheritable_attribute("after_filters")
      end
      
      private
        def append_filter(condition, filters)
          write_inheritable_array("#{condition}_filters", filters)
        end

        def prepend_filter(condition, filters)
          write_inheritable_attribute("#{condition}_filters", filters + read_inheritable_attribute("#{condition}_filters"))
        end
    end

    module InstanceMethods # :nodoc:
      def self.append_features(base)
        super
        base.class_eval {
          alias_method :perform_action_without_filters, :perform_action
          alias_method :perform_action, :perform_action_with_filters
        }
      end

      def perform_action_with_filters
        return if before_action == false
        perform_action_without_filters
        after_action
        close_session
      end

      # Calls all the defined before-filter filters, which are added by using "before_filter :method".
      # If any of the filters return false, no more filters will be executed and the action is aborted.
      def before_action #:doc:
        call_filters(self.class.before_filters)
      end

      # Calls all the defined after-filter filters, which are added by using "after_filter :method".
      # If any of the filters return false, no more filters will be executed.
      def after_action #:doc:
        call_filters(self.class.after_filters)
      end
      
      private
        def call_filters(filters)
          filters.each do |filter| 
            if Symbol === filter
              if self.send(filter) == false then return false end
            elsif filter_block?(filter)
              if filter.call(self) == false then return false end
            elsif filter_class?(filter)
              if filter.filter(self) == false then return false end
            else
              raise(
                ActionControllerError, 
                "Filters need to be either a symbol, proc/method, or class implementing a static filter method"
              )
            end
          end
        end
        
        def filter_block?(filter)
          filter.respond_to?("call") && (filter.arity == 1 || filter.arity == -1)
        end
        
        def filter_class?(filter)
          filter.respond_to?("filter")
        end
    end
  end
end