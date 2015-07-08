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

  goodFileContent = '{
                    "DEPLOY": [
                                {
                                    "BUILD_NUMBER": "123",
                                    "GIT_COMMIT":"4324235fdd",
                                    "GIT_BRANCH":"branch1",
                                    "BUILD_URL":"buildURL1",
                                    "GIT_URL":"gitUrl1",
                                    "JOB_NAME":"MyFirstJobName"
                                },
                                {
                                    "BUILD_NUMBER": "456",
                                    "GIT_COMMIT":"b72136305a436271829c128ebf35d9fc4dc786b4",
                                    "GIT_BRANCH":"branch2",
                                    "BUILD_URL":"buildURL2",
                                    "GIT_URL":"gitUrl2",
                                    "JOB_NAME":"MySecondJobName"
                                }
                              ]

                  }'
 invalidFileContentWithEndMissing = '{
                    "DEPLOY": [
                                {
                                    "BUILD_NUMBER": "123",
                                    "GIT_COMMIT":"4324235fdd",
                                    "GIT_BRANCH":"branch1",
                                    "BUILD_URL":"buildURL1",
                                    "GIT_URL":"gitUrl1",
                                    "JOB_NAME":"MyFirstJobName"
                                '
 
  it "returns an empty hash when pass an invalid JSON structure" do
    expect(@tracker.getJSONHash invalidFileContentWithEndMissing).to eq(nil)
  end

  it "returns hash when passed a valid JSON structure" do
    expect(@tracker.getJSONHash goodFileContent).not_to be_nil
  end
end

describe "#JSON handling" do
  goodFileContent = '{
                    "DEPLOY": [
                                {
                                    "BUILD_NUMBER": "123",
                                    "GIT_COMMIT":"4324235fdd",
                                    "GIT_BRANCH":"branch1",
                                    "BUILD_URL":"buildURL1",
                                    "GIT_URL":"gitUrl1",
                                    "JOB_NAME":"MyFirstJobName"
                                },
                                {
                                    "BUILD_NUMBER": "456",
                                    "GIT_COMMIT":"b72136305a436271829c128ebf35d9fc4dc786b4",
                                    "GIT_BRANCH":"branch2",
                                    "BUILD_URL":"buildURL2",
                                    "GIT_URL":"gitUrl2",
                                    "JOB_NAME":"MySecondJobName"
                                }
                              ]

                  }'

  before :each do
    @tracker = UploadFileTracker.new
    @tracker.getJSONHash goodFileContent
  end

  it "does not find sha from passed in SHA in the text" do
    gitCommit = "7"
    expect(@tracker.foundSha(gitCommit).size()).to eq(0)
  end

  it "does find sha from from passed in SHA in the text" do
    gitCommit = "b72136305a436271829c128ebf35d9fc4dc786b4"
    entry = @tracker.foundSha gitCommit
    puts entry.class
    puts entry.size
    puts entry
    puts entry.collect {|item| item[:GIT_COMMIT]}
    # entry.each do |(a,b)|
    #   puts a,b 
    # end
    expect(entry["GIT_COMMIT"]).to eq("b72136305a436271829c128ebf35d9fc4dc786b4")
  end
end