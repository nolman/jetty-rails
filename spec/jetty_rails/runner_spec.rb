require File.dirname(__FILE__) + '/../spec_helper'

describe JettyRails::Runner, "with no extra configuration" do
  it "should require basedir to be run" do
    lambda { JettyRails::Runner.new }.should raise_error 
  end
  
  it "should receive basedir configuration" do
    runner = JettyRails::Runner.new :base => '/any/app/dir'
    runner.config.should have_key(:base)
    runner.config[:base].should eql('/any/app/dir')
  end
  
  it "should default to development environment" do
    runner = JettyRails::Runner.new :base => Dir.pwd
    runner.config.should have_key(:environment)
    runner.config[:environment].should eql('development')
    runner.app_context.init_params['rails.env'].should eql('development')
  end
  
  it "should default to the root context path" do
    runner = JettyRails::Runner.new :base => Dir.pwd
    runner.config.should have_key(:context_path)
    runner.config[:context_path].should eql('/')
    runner.app_context.context_path.should eql('/')
  end
  
  it "should set rails root" do
    runner = JettyRails::Runner.new :base => Dir.pwd
    runner.app_context.init_params['rails.root'].should eql('/')
  end
  
  it "should set public root" do
    runner = JettyRails::Runner.new :base => Dir.pwd
    runner.app_context.init_params['public.root'].should eql('/public')
  end
  
  it "should set gem path" do
    runner = JettyRails::Runner.new :base => Dir.pwd
    runner.app_context.init_params['gem.path'].should eql('tmp/war/WEB-INF/gems')
  end
  
  it "should install RailsServletContextListener" do
    runner = JettyRails::Runner.new :base => Dir.pwd
    listeners = runner.app_context.event_listeners
    listeners.size.should eql(1)
    listeners[0].should be_kind_of(Rack::RailsServletContextListener)
  end
  
  it "should install RackFilter" do
    context = mock("web application context", :null_object => true)
    server = Jetty::Server.new
    context.stub!(:getServer).and_return(server)
    Jetty::Handler::WebAppContext.should_receive(:new).and_return(context)
    context.should_receive(:add_filter).once do |filter_holder, url_pattern, dispatches|
      filter_holder.filter.should be_kind_of(Rack::RackFilter)
      url_pattern.should eql('/*')
      dispatches.should eql(Jetty::Context::DEFAULT)
    end
    runner = JettyRails::Runner.new :base => Dir.pwd
  end
  
end

describe JettyRails::Runner, "with custom configuration" do
  
  it "should allow to override the environment" do
    runner = JettyRails::Runner.new :base => Dir.pwd, :environment => 'production'
    runner.config.should have_key(:environment)
    runner.config[:environment].should eql('production')
    runner.app_context.init_params['rails.env'].should eql('production')
  end
  
  it "should allow to override the context path" do
    runner = JettyRails::Runner.new :base => Dir.pwd, :context_path => "/myapp" 
    runner.config.should have_key(:context_path)
    runner.config[:context_path].should eql('/myapp')
    runner.app_context.context_path.should eql('/myapp')
  end
  
end
