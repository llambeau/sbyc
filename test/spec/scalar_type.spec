require 'sbyc'
describe ::SByC::ScalarType do
  
  it "should allow creating types with representations" do
    length = ::SByC::System::ScalarType() {
      representation :CM,   :cm   => Float
      representation :Inch, :inch => Float
      converter(:CM => :Inch){|from,to| to.inch = from.cm/2.54}
      converter(:Inch => :CM){|from,to| to.cm = from.inch*2.54}
    }
    length.should respond_to(:CM)
    length.should respond_to(:Inch)
    length::CM(:cm => 2.54).cm.should == 2.54
    length::Inch(:inch => 1.0).inch.should == 1.0
    length::CM(:cm => 2.54).inch.should == 1.0
    length::Inch(:inch => 1.0).cm.should == 2.54
  end
  
  it "should allow shortcuts when only one representation exists" do
    length = ::SByC::System::ScalarType(:cm => Float)
    length::Main[12.0].cm.should == 12.0
  end
  
  # it "should allow creating simple types with a major anonymous physical representation" do
  #   mail = ::SByC::System::ScalarType(String){
  #     constraint{|m| m.physrep =~ /^[a-z]+@[a-z]+\.[a-z]{3}$/ }
  #   }
  #   lambda { mail["blambeau@gmail.com"] }.should_not raise_error(::SByC::TypeError)
  #   lambda { mail["hello"] }.should raise_error(::SByC::TypeError)
  # end
  # 
  # it "should allow creating simple types with multiple selectors" do
  #   mail = ::SByC::System::ScalarType() do
  #     constraint{|m| m.physrep =~ /^[a-z]+@[a-z]+\.[a-z]{3}$/}
  #     selector(String){|m, s| m.physrep = s                         }
  #     selector(String, String){|m, user, host| m.physrep = "#{user}@#{host}"}
  #   end
  #   (mail === mail["blambeau@gmail.com"]).should be_true
  #   (mail === mail["blambeau", "gmail.com"]).should be_true
  # end
  # 
  
  # it "should allow creating complex types" do
  #   natural = Fixnum.such_that{|i| i > 0}
  #   rectangle = ::SByC::System::ScalarType(:width => natural, :length => natural)
  #   r = rectangle[:width => 10, :length => 20]
  #   (rectangle === r).should be_true
  #   r.width.should == 10
  #   r.length.should == 20
  # end
  # 
  # it "should allow creating new values by copy-and-modify" do
  #   natural = Fixnum.such_that{|i| i > 0}
  #   rectangle = ::SByC::System::ScalarType(:width => natural, :length => natural)
  #   r = rectangle[:width => 10, :length => 20]
  #   r2 = r.update(:length => 30)
  #   r2.length.should == 30
  # end
  # 
  # it "should allow constraining complex types" do
  #   natural = Fixnum.such_that{|i| i > 0}
  #   rectangle = ::SByC::System::ScalarType(:width => natural, :length => natural)
  #   square = rectangle.such_that{|r| r.width == r.length}
  #   lambda {square[:width => 10, :length => 10]}.should_not raise_error
  #   lambda {square[:width => 10, :length => 20]}.should raise_error(::SByC::TypeError)
  #   lambda {square[:width => 10, :length => 0]}.should raise_error(::SByC::TypeError)
  #   rectangle[:width => 10, :length => 10].belongs_to?(square).should be_true
  # end
  
end