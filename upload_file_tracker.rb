class UploadFileTracker
  def targetDirectory
    File.expand_path(File.dirname(__FILE__) + '/ci') 
  end
end