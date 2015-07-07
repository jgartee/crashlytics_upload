require 'json'

ciDirectory = File.expand_path(File.dirname(__FILE__))
nasMountPoint = '/Network/NAS'

isItMounted = `mount | grep %%NAS_MOUNT_POINT%%`

if(isItMounted == "") then
  nasMountPoint = ciDirectory
end

trackingFile=nasMountPoint+"/"+ENV["JOB_NAME"]+"CrashalyticsUpload.json"

puts (nasMountPoint)

if(!File.exist?(trackingFile)) then
  File.new(trackingFile,"w") 
end

# read json file and look for current sha stored in GIT_COMMIT
if (File.size?(trackingFile) == nil)
  puts("Empty file")
  exit 0
end

file = File.read(trackingFile)
data_hash = JSON.parse(file)

# if SHA found then abort build on Jenkins making it a grey build, add dedcriptive error message.
values = data_hash['DEPLOY']

item = -1

for index in 0 ... values.size
  if( values[index]['GIT_COMMIT'] == ENV['GIT_COMMIT']) then
    item = index
    break
  end
end

if( item >= 0) then
  puts("this commit has been pushed before...aborting the upload:  " )
  puts(values[item]['JOB_NAME'])
  puts(values[item]['BUILD_URL'])

  exit 0
end


#data_hash['DEPLOY'] => []
#commit = values['GIT_COMMIT']
#commit = values['GIT_COMMIT']
#element = values.index(0)
#puts "#{commit}"

# if happy path, not found, end ruby.