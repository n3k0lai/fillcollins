set :public_folder, File.dirname(__FILE__) + '/public'
set :generated_images_folder, File.dirname(__FILE__) + '/images/generated'
set :images_folder, File.dirname(__FILE__) + '/images/source'
set :static_cache_control, [:public, :max_age => 300]
gabba = Gabba::Gabba.new("UA-33854875-1", "fill-murray.com")

before do
  pass if request.path. == '/'
  cache_control :public, :max_age => 31536000
  check_sizes
end

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

not_found do
  send_file File.join(settings.public_folder, '404.html')
end

error 422 do
  send_file File.join(settings.public_folder, '422.html')
end

error 500 do
  send_file File.join(settings.public_folder, '500.html')
end

get '/:both' do
  width = params[:both].to_i
  height = params[:both].to_i
  gabba.page_view("Show", "#{width}/#{height}")
  return_image(width, height)
end

get '/:both/' do
  width = params[:both].to_i
  height = params[:both].to_i
  gabba.page_view("Show", "#{width}/#{height}")
  return_image(width, height)
end

get '/g/:both' do
  width = params[:both].to_i
  height = params[:both].to_i
  gabba.page_view("ShowGray", "g/#{width}/#{height}")
  return_image(width, height, :grayscale)
end

get '/g/:both/' do
  width = params[:both].to_i
  height = params[:both].to_i
  gabba.page_view("ShowGray", "g/#{width}/#{height}")
  return_image(width, height, :grayscale)
end

get '/:width/:height' do
  width = params[:width].to_i
  height = params[:height].to_i
  gabba.page_view("Show", "#{width}/#{height}")
  return_image(width, height)
end

get '/:width/:height/' do
  width = params[:width].to_i
  height = params[:height].to_i
  gabba.page_view("Show", "#{width}/#{height}")
  return_image(width, height)
end

get '/g/:width/:height' do
  width = params[:width].to_i
  height = params[:height].to_i
  gabba.page_view("ShowGray", "g/#{width}/#{height}")
  return_image(width, height, :grayscale)
end

get '/g/:width/:height/' do
  width = params[:width].to_i
  height = params[:height].to_i
  gabba.page_view("ShowGray", "g/#{width}/#{height}")
  return_image(width, height, :grayscale)
end
private
	def check_sizes

    matches = /\/(\d+)\/(\d+)/.match(request.path)
    if matches != nil
  		width = matches[1].to_i
  		height = matches[2].to_i
      raise error 'Bad Request' if height == nil || width == nil || height < 1 || width < 1
      raise error 'Too Large' if height > 3500 || width > 3500
    else
      matches = /\/(\d+)/.match(request.path)
      if matches != nil
    		width = matches[1].to_i
    		height = matches[1].to_i
        raise error 'Bad Request' if height == nil || width == nil || height < 1 || width < 1
        raise error 'Too Large' if height > 3500 || width > 3500
      else
        raise error 'Bad Request'
      end
    end
	end

	def return_image(width, height, *args)
		grayscale = args.include?(:grayscale)
		filename = get_image_filename(width, height, grayscale)
    send_file filename, type: 'image/jpeg', disposition: 'inline'
	end

	def get_image_filename(width, height, grayscale=false)
		path = []
		path << 'grayscale' if grayscale
		path << "#{width}x#{height}.jpg"

    # send_file File.join(settings.public_folder, 'index.html')
    filename = File.join(settings.generated_images_folder, *path)
		return filename if FileTest.exists?(filename)

		original_path = []
		original_path << '*.*'
    original_filename = Dir.glob(File.join(settings.images_folder, *original_path)).sample

		image_original = Magick::Image.read(original_filename).first
		image = image_original.resize_to_fill(width,height)
		image = image.quantize(256,Magick::GRAYColorspace) if grayscale
		image.write(filename)
		filename
	end
