module ActionController
  # Polymorphic URL helpers are methods for smart resolution to a named route call when
  # given an ActiveRecord model instance. They are to be used in combination with
  # ActionController::Resources.
  #
  # These methods are useful when you want to generate correct URL or path to a RESTful
  # resource without having to know the exact type of the record in question.
  #
  # Nested resources and/or namespaces are also supported, as illustrated in the example:
  #
  #   polymorphic_url([:admin, @article, @comment])
  #   #-> results in:
  #   admin_article_comment_url(@article, @comment)
  #
  # == Usage within the framework
  #
  # Polymorphic URL helpers are used in a number of places throughout the Rails framework:
  #
  # * <tt>url_for</tt>, so you can use it with a record as the argument, e.g.
  #   <tt>url_for(@article)</tt>;
  # * ActionView::Helpers::FormHelper uses <tt>polymorphic_path</tt>, so you can write
  #   <tt>form_for(@article)</tt> without having to specify :url parameter for the form
  #   action;
  # * <tt>redirect_to</tt> (which, in fact, uses <tt>url_for</tt>) so you can write
  #   <tt>redirect_to(post)</tt> in your controllers;
  # * ActionView::Helpers::AtomFeedHelper, so you don't have to explicitly specify URLs
  #   for feed entries.
  #
  # == Prefixed polymorphic helpers
  #
  # In addition to <tt>polymorphic_url</tt> and <tt>polymorphic_path</tt> methods, a
  # number of prefixed helpers are available as a shorthand to <tt>:action => "..."</tt>
  # in options. Those are:
  #
  # * <tt>edit_polymorphic_url</tt>, <tt>edit_polymorphic_path</tt>
  # * <tt>new_polymorphic_url</tt>, <tt>new_polymorphic_path</tt>
  # * <tt>formatted_polymorphic_url</tt>, <tt>formatted_polymorphic_path</tt>
  #
  # Example usage:
  #
  #   edit_polymorphic_path(@post)
  #   #=> /posts/1/edit
  #
  #   formatted_polymorphic_path([@post, :pdf])
  #   #=> /posts/1.pdf
  module PolymorphicRoutes
    # Constructs a call to a named RESTful route for the given record and returns the
    # resulting URL string. For example:
    #
    #   polymorphic_url(post)
    #   # calls post_url(post) #=> "http://example.com/posts/1"
    #
    # ==== Options
    # * <tt>:action</tt> -- specifies the action prefix for the named route:
    #   <tt>:new</tt>, <tt>:edit</tt> or <tt>:formatted</tt>. Default is no prefix.
    # * <tt>:routing_type</tt> -- <tt>:path</tt> or <tt>:url</tt> (default <tt>:url</tt>).
    #
    # ==== Examples
    #
    #   # an Article record
    #   polymorphic_url(record)  #->  article_url(record)
    #
    #   # a Comment record
    #   polymorphic_url(record)  #->  comment_url(record)
    #
    #   # it recognizes new records and maps to the collection
    #   record = Comment.new
    #   polymorphic_url(record)  #->  comments_url()
    #
    def polymorphic_url(record_or_hash_or_array, options = {})
      record    = extract_record(record_or_hash_or_array)
      format    = (options[:action].to_s == "formatted" and record_or_hash_or_array.pop)
      namespace = extract_namespace(record_or_hash_or_array)
      
      args = case record_or_hash_or_array
        when Hash;  [ record_or_hash_or_array ]
        when Array; record_or_hash_or_array.dup
        else        [ record_or_hash_or_array ]
      end

      args << format if format

      inflection =
        case
        when options[:action].to_s == "new"
          args.pop
          :singular
        when record.respond_to?(:new_record?) && record.new_record?
          args.pop
          :plural
        else
          :singular
        end
      
      named_route = build_named_route_call(record_or_hash_or_array, namespace, inflection, options)
      send!(named_route, *args)
    end

    # Returns the path component of a URL for the given record. It uses
    # <tt>polymorphic_url</tt> with <tt>:routing_type => :path</tt>.
    def polymorphic_path(record_or_hash_or_array, options = {})
      options[:routing_type] = :path
      polymorphic_url(record_or_hash_or_array, options)
    end

    %w(edit new formatted).each do |action|
      module_eval <<-EOT, __FILE__, __LINE__
        def #{action}_polymorphic_url(record_or_hash)
          polymorphic_url(record_or_hash, :action => "#{action}")
        end

        def #{action}_polymorphic_path(record_or_hash)
          polymorphic_url(record_or_hash, :action => "#{action}", :routing_type => :path)
        end
      EOT
    end

    private
      def action_prefix(options)
        options[:action] ? "#{options[:action]}_" : ""
      end

      def routing_type(options)
        options[:routing_type] || :url
      end

      def build_named_route_call(records, namespace, inflection, options = {})
        unless records.is_a?(Array)
          record = extract_record(records)
          route  = ''
        else
          record = records.pop
          route = records.inject("") do |string, parent|
            string << "#{RecordIdentifier.send!("singular_class_name", parent)}_"
          end
        end

        route << "#{RecordIdentifier.send!("#{inflection}_class_name", record)}_"

        action_prefix(options) + namespace + route + routing_type(options).to_s
      end

      def extract_record(record_or_hash_or_array)
        case record_or_hash_or_array
          when Array; record_or_hash_or_array.last
          when Hash;  record_or_hash_or_array[:id]
          else        record_or_hash_or_array
        end
      end
      
      def extract_namespace(record_or_hash_or_array)
        returning "" do |namespace|
          if record_or_hash_or_array.is_a?(Array)
            record_or_hash_or_array.delete_if do |record_or_namespace|
              if record_or_namespace.is_a?(String) || record_or_namespace.is_a?(Symbol)
                namespace << "#{record_or_namespace}_"
              end
            end
          end  
        end
      end
  end
end
