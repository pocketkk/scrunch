require_relative '../scrunch'

describe Scrunch do

  it "scrunch should be valid" do
    s = Scrunch.new
  end

  it "scrunch#open" do
    File.open("tmp", "w") { |f| f.write "TESTtestTEST" }
    s = Scrunch.new
    s.open("tmp")
    expect(s.document).to eq("TESTtestTEST")
    File.delete("tmp")
  end

  it "scrunch#save" do
    s = Scrunch.new
    s.document = "Saving this to a file"
    s.save("tmp")
    File.open("tmp", "r") { 
      expect(s.document).to eq("Saving this to a file")
    }
    File.delete("tmp")
  end

  it "scrunch#create" do
    s = Scrunch.new
    s.create('my_filename.rb')
    expect(s.file_name).to eq('my_filename.rb')
  end

  it "scrunch#footer" do
    s = Scrunch.new
    s.create('my_filename.rb')
    expect(s.footer).to include('my_filename.rb')
  end
end