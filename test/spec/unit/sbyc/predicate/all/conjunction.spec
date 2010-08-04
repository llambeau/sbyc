require File.expand_path('../../../../../spec_helper', __FILE__)
describe "Predicate::All::conjunction" do
  
  let(:left) { SByC::Predicate::ALL }
  subject{ left.conjunction(right) }
  
  describe "All & None" do
    let(:right){ SByC::Predicate::NONE }
    it{ should == SByC::Predicate::NONE }
  end
  
  describe "All & All" do
    let(:right){ SByC::Predicate::ALL }
    it{ should == SByC::Predicate::ALL }
  end
  
  describe "All & BelongsTo" do
    let(:right){ SByC::Predicate::BelongsTo.new(:hello, [:x, :y]) }
    it{ should == right }
  end
  
end