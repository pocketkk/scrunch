Dir["./lib/*.rb"].each { |f| load(f) }

describe Window do
  let(:window) { Window.new }
  
  it "window should be valid" do
    expect(window.class).to be_instance_of(Window.class)
  end

  it "should have a height" do
    expect(window.height).to eq(0)
  end

  it "should have a width" do
  	expect(window.width).to eq(0)
  end

  it "should have a cursor" do
  	expect(window.cursor.class).to be_instance_of(Cursor.class)
  end

  it "should have a mode" do
  	expect(window.mode.nil?).not_to be(true)
  end

  it "should return window_size" do 
  	#TODO: stub this method for testing
  end

  it 'window#show' do

  end

end
