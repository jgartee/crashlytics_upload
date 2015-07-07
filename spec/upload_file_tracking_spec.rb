
require 'spec_helper'

describe "#Manage file i/o" do
  
  before :each do
    @tracker = UploadFileTracker.new
  end

  it "creates an object of the correct type" do
    expect(@tracker).to be_a UploadFileTracker
  end

  it "returns the CI directory when /Network/NAS/nas_root is not available" do
    expect(@tracker.targetDirectory).to eq(File.expand_path(File.dirname(__FILE__) + '/../ci'))
  end
end
