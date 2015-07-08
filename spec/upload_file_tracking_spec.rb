require 'spec_helper'

describe "#Manage file i/o" do

  let (:fake_File) {gimme(File)}
  
  before :each do
    @tracker = UploadFileTracker.new
    ENV['JOB_NAME']='ourJobName'
    give!(fake_File).expand_path(anything) {"expandedDirName"}
    give!(fake_File).dirname(anything) {"dirName"}
  end

  it "creates an object of the correct type" do
    expect(@tracker).to be_a UploadFileTracker
  end

  it "returns the CI directory when /Network/NAS/nas_root is not available" do
    give(Dir).exist?('/Network/NAS/nas_root') {false}
    expect(@tracker.targetDirectory).to eq(File.expand_path(File.dirname(__FILE__) + '/../ci'))
  end

  it "returns /Network/NAS/nas_root when the NAS is available" do
    give(Dir).exist?('/Network/NAS/nas_root') {true}
    expect(@tracker.targetDirectory).to eq('/Network/NAS/nas_root')  
  end

  it "retuns the full path of the tracking file" do
    expect(@tracker.trackingFile.end_with?('/'+ENV['JOB_NAME']+'CrashalyticsUpload.json'))
  end
  
  it "returns the nas-based tracking file when /Network/NAS/nas_root is available" do
    give(Dir).exist?('/Network/NAS/nas_root') {true}
    expect(@tracker.trackingFile).to eq('/Network/NAS/nas_root/'+ENV['JOB_NAME']+'CrashalyticsUpload.json')
  end

  it "returns the CI-based mount tracking file when /Network/NAS/nas_root is not available" do
    give(Dir).exist?('/Network/NAS/nas_root') {false}
    expect(@tracker.trackingFile).to eq(File.expand_path(File.dirname(__FILE__) + '/../ci') +'/' + ENV['JOB_NAME']+'CrashalyticsUpload.json')
  end

  it "creates a new tracking file if one does not already exist" do
    localTracker = UploadFileTracker.new fake_File
    give(Dir).exist?('/Network/NAS/nas_root') {false}
   
    localTracker.getFileContents

    verify!(fake_File).new(localTracker.trackingFile,"w")
  end

  it "does not create a new tracking file if one already exists" do
    tracker = UploadFileTracker.new fake_File
    give(Dir).exist?('/Network/NAS/nas_root') {false}
    give!(fake_File).size?(anything) {1}
    give!(fake_File).exist?(anything) {true}
    give!(fake_File).read(anything) {"This is my data"} 

    expect(tracker.getFileContents).to eq('This is my data')
    
    verify!(fake_File,0).new(anything,"w")
  end

  it "does not read the file if the file size is nil" do
    tracker = UploadFileTracker.new fake_File
    give!(fake_File).exist?(anything) {true}
    give!(fake_File).size?(anything) {nil}
        
    tracker.getFileContents

    verify!(fake_File,0).read(anything)
  end
end
