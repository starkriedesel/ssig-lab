module ApplicationHelper
  @@markdown_identifier = '#markdown#'

  # Checks if the text is using markdown
  def check_with_markdown(text)
    text.starts_with? @@markdown_identifier
  end

  # Changes the text to include the markdown identifier
  def save_with_markdown(text, use_markdown)
    if use_markdown
      @@markdown_identifier+text
    else
      text
    end
  end

  # Removes the identifier is markdown is being used
  def load_with_markdown(text, use_markdown)
    if use_markdown
      text[@@markdown_identifier.length..-1]
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
