require 'json'

class UploadFileTracker

  def initialize file = File
    @file = file
  end

  def targetDirectory
    ciDirectory = @file.expand_path(@file.dirname(__FILE__) + '/ci')
    nasMountPoint = '/Network/NAS/nas_root'
    nasMountPoint = ciDirectory unless Dir.exist?(nasMountPoint)
    nasMountPoint 
  end

  def trackingFile
    targetDirectory + "/" + ENV["JOB_NAME"] + "CrashalyticsUpload.json"
  end

  def getFileContents
    if(!@file.exist?(trackingFile)) then
      @file.new(trackingFile,"w") 
    end

    contents = @file.read(trackingFile) if @file.size?(trackingFile) != nil
    contents
  end
  
  @jsonHash = nil

  def getJSONHash filecontent
    begin
      @jsonHash = JSON.parse(filecontent) if @jsonHash == nil
    rescue
      nil
    end
  end

  def findJsonEntryBySha gitSha

    values = @jsonHash['DEPLOY']
    result = values.select { | item | item["GIT_COMMIT"] == gitSha}

    if(result.size > 1) then
      raise 'Multiple uploads detected for sha:  ' + gitSha.to_s
    end

    result
  end

  def addJob gitCommit, buildNumber, gitBranch, buildUrl, gitUrl, jobName

    raise 'Missing parameter.' if gitCommit == nil || buildNumber == nil || gitBranch == nil || buildUrl == nil || gitUrl == nil || jobName == nil

    @jsonHash["DEPLOY"] <<  { BUILD_NUMBER: buildNumber,
                              GIT_COMMIT:  gitCommit,
                              GIT_BRANCH:  gitBranch,
                              BUILD_URL:   buildUrl,
                              GIT_URL:     gitUrl,
                              JOB_NAME:    jobName
                            }
    @jsonHash =JSON.parse(@jsonHash.to_json)
  end
end