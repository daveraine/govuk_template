require 'spec_helper'
require File.join(PROJECT_ROOT, 'build_tools/compiler/jinja_processor.rb')

def valid_sections
  {
    after_header: "{% block after_header %}{% endblock %}",
    body_classes: "{% block body_classes %}{% endblock %}",
    body_end: "{% block body_end %}{% endblock %}",
    content: "{% block content %}{% endblock %}",
    cookie_message: "{% block cookie_message %}{% endblock %}",
    footer_support_links: "{% block footer_support_links %}{% endblock %}",
    footer_top: "{% block footer_top %}{% endblock %}",
    head: "{% block head %}{% endblock %}",
    header_class: "{% block header_class %}{% endblock %}",
    html_lang: "{{ html_lang|default('en') }}",
    inside_header: "{% block inside_header %}{% endblock %}",
    page_title: "{% block page_title %}GOV.UK - The best place to find government services and information{% endblock %}",
    proposition_header: "{% block proposition_header %}{% endblock %}",
    top_of_page: "{% block top_of_page %}{% endblock %}"

  }
end

describe Compiler::JinjaProcessor do

  let(:file) {"some/file.erb"}
  subject {described_class.new(file)}


  describe "#handle_yield" do
    valid_sections.each do |key, content|
      it "should render #{content} for #{key}" do
        subject.handle_yield(key).should == content
      end
    end
  end

  describe "#content_for?" do
    valid_sections.each do |k,v|
      it "should return true for #{k}" do
        subject.content_for?(k).should be_true
      end
    end

    context "when the yield is not handled" do
      let(:invalid_yield) {:hello_there}

      it "should be false for an invalid yield key" do
        subject.content_for?(invalid_yield).should be_false
      end
    end
  end

  describe "#asset_path" do
    context "if file is stylesheet" do
      let(:asset_file) {"a/file.css"}
      before do
        subject.instance_variable_set(:@is_stylesheet, true)
      end
      it "should return the file" do
        subject.asset_path(asset_file).should == "#{asset_file}?#{GovukTemplate::VERSION}"
      end
    end
    context "if not stylesheet" do
      context "if css file path passed in" do
        let(:css_asset_file) {"a/file.css"}
        it "should return the correct path for a stylesheet" do
          subject.asset_path(css_asset_file).should == "{{ asset_path }}stylesheets/#{css_asset_file}?#{GovukTemplate::VERSION}"
        end
      end
      context "if javascript file path passed in" do
        let(:js_asset_file) {"a/file.js"}
        #up for debate - whole project is js
        it "should return the correct path for a javascript file" do
          subject.asset_path(js_asset_file).should == "{{ asset_path }}javascripts/#{js_asset_file}?#{GovukTemplate::VERSION}"
        end
      end
      context "if other file path passed in" do
        let(:other_asset_file) {"a/file.png"}
        it "should return the correct path for an image" do
          subject.asset_path(other_asset_file).should == "{{ asset_path }}images/#{other_asset_file}?#{GovukTemplate::VERSION}"
        end
      end
    end
  end

end
