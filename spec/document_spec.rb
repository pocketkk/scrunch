require_relative '../lib/document'

describe Document do

  let(:document) { Document.new("Test text") }

  it "document should be valid" do
    expect(document.class).to be_instance_of(Document.class)
  end

  it 'document#initialize should accept text' do
  	expect(document.text).to eq("Test text")
  end

  it 'document#height' do
  	document.text = "This has\n2lines"
  	expect(document.height).to eq(2)
  end

  it 'document#width' do
  	document.text = "This has width\n\n12345\n"
  	expect(document.width(3)).to eq(5)
  end

  it 'document#width should fail silently if y' do
  	expect(document.width(100)).to eq(0)
  end


end
