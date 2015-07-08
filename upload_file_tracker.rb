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
    @file.new(trackingFile,"w")
    ""
  end
end