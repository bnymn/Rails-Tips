# Change paperclip attachment :path
# 
# This task moves your attachements from old :path to new :path.
# I used lots of interpolations in old :path, so in order to
# move attachments correctly, I had to used interpolations explicitly.
# 
# Apparently, Paperclip::Attachement.interpolate method is private. So
# I copied its body, which is interpolator.interpolate(pattern, self, style_name)

namespace :paperclip do
  task :move_attachments => :environment do
    News.find_each do |item|
        old_pattern = "#{Rails.root}/public/system/:class/:id_partition/:style/:id.:extension"
        
        filename = Paperclip::Interpolations.interpolate(old_pattern, item.image, :original)
        if File.exists? filename
          puts "Re-saving image attachment #{item.id} - #{filename}"
          image = File.new filename
          item.image = image
          item.save
          
          # if there are multiple styles, you want to recreate them :
          post.image.reprocess! 
          image.close

          # Since we copied from old location, we can now safely delete the old one.
          File.delete(filename)
        end
    end
  end
end