require File.expand_path('../../../../../spec_helper', __FILE__)

describe "SByC::Rewriter::IMatch#args_match" do

  let(:imatch) { ::SByC::Rewriter::IMatch.new nil }

  context "when called with a capture match" do
    let(:matcher)    { ::SByC::parse{ x }  }
    let(:matched)    { ::SByC::parse{ 12 } }
    let(:match_data) { { }                 }
    let(:subject) { imatch.args_match([ matcher ], [ matched ], match_data)}
    
    specify {
      subject.should be_true
      match_data[:x].should == matched
    }
  end

  context "when called with a literal match" do
    let(:matcher)    { ::SByC::parse{ 12 }  }
    let(:matched)    { ::SByC::parse{ 12 } }
    let(:match_data) { { }                 }
    let(:subject) { imatch.args_match([ matcher ], [ matched ], match_data)}
    
    specify { subject.should be_true }
  end

  context "when called with a literal no-match" do
    let(:matcher)    { ::SByC::parse{ 13 }  }
    let(:matched)    { ::SByC::parse{ 12 } }
    let(:match_data) { { }                 }
    let(:subject) { imatch.args_match([ matcher ], [ matched ], match_data)}
    
    specify { subject.should be_false }
  end
  
  context "when called with a recursive match" do
    let(:matcher)    { ::SByC::parse{ (match :hello, x) } }
    let(:matched)    { ::SByC::parse{ (hello "SByC")   } }
    let(:match_data) { { }                             }
    let(:subject) { imatch.args_match([ matcher ], [ matched ], match_data)}
    
    specify { 
      subject.should be_true 
      match_data.key?(:x).should be_true
    }
  end

  context "when called with a recursive no-match" do
    let(:matcher)    { ::SByC::parse{ (match :hello, "world") } }
    let(:matched)    { ::SByC::parse{ (hello 12)              } }
    let(:match_data) { { }                             }
    let(:subject) { imatch.args_match([ matcher ], [ matched ], match_data)}
    
    specify { subject.should be_false }
  end

end