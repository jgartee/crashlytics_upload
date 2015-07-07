
require 'spec_helper'

describe "#Manage file i/o" do
  
  before :each do
    @tracker = UploadFileTracker.new
  end

  it "creates an object of the correct type" do
    expect(@tracker).to be_a UploadFileTracker
  end
end
