require_relative '../lib/document'

describe Document do

  it "document should be valid" do
    d = Document.new
    expect(d.class).to eq('Document')
  end
end
