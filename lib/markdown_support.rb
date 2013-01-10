module MarkdownSupport

  def with_markdown(*attr_names)
    cattr_accessor :markdown_attr_list
    self.markdown_attr_list ||= []

    cattr_accessor :markdown_identifier
    self.markdown_identifier = '#markdown#'

    include InstanceMethods

    markdown_attr attr_names

    before_save :markdown_save
    after_find :markdown_find
  end

  def markdown_attr *attr_names
    new_attrs = attr_names - self.markdown_attr_list
    new_attrs.first.each do |attr_name|
      send :define_method, "#{attr_name}_html" do
       instance_eval "self.class.show_with_markdown self.#{attr_name}, self.#{attr_name}_use_markdown"
      end
      send :attr_accessor, "#{attr_name}_use_markdown"
      send :attr_accessible, "#{attr_name}_use_markdown"
      self.markdown_attr_list << attr_name
    end
  end

  module InstanceMethods
    def markdown_save
      self.class.markdown_attr_list.each do |attr_name|
        source_code = %Q{
          self.#{attr_name}_use_markdown = self.#{attr_name}_use_markdown == '1'
          self.#{attr_name} = self.class.save_with_markdown self.#{attr_name}, self.#{attr_name}_use_markdown
        }
        instance_eval source_code
      end
    end

    def markdown_find
      self.class.markdown_attr_list.each do |attr_name|
        source_code = %Q{
          if self.#{attr_name}?
            self.#{attr_name}_use_markdown = self.class.check_with_markdown self.#{attr_name}
            self.#{attr_name}= self.class.load_with_markdown self.#{attr_name}, self.#{attr_name}_use_markdown
          end
        }
        instance_eval source_code
      end
    end
  end

  # Checks if the text is using markdown
  def check_with_markdown(text)
    text.starts_with? self.markdown_identifier
  end

  # Changes the text to include the markdown identifier
  def save_with_markdown(text, use_markdown)
    if use_markdown
      self.markdown_identifier+text
    else
      text
    end
  end

  # Removes the identifier is markdown is being used
  def load_with_markdown(text, use_markdown)
    if use_markdown
      text[self.markdown_identifier.length..-1]
    else
      text
    end
  end

  # If markdown is being used, render HTML
  # This also escapes any non-markdown HTML
  # and is safe to render directly
  def show_with_markdown(text, use_markdown)
    if use_markdown
      RDiscount.new(CGI::escapeHTML(text)).to_html.html_safe
    else
      text
    end
  end
end
