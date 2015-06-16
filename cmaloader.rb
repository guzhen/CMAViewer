class CMAApp
	#FOLDERS=["app","appmeta","license","patch","savedata","sce_sys",]
	PATH='APP'

	def initialize
		@info={'path'=>'','user'=>[]}
		@data={}
	end

	def load(path)
		apppath = File.join(File.realpath(path),PATH)
		Dir.chdir apppath do
			@info[:path]=apppath
			@info[:user]=Dir.entries('.').select{|e| e!='.' && e!='..'}
			return @info[:user]
		end
	end

	def select(user)
		if @info[:user].include?(user)==false
			return nil
		end
		if @data.has_key?(user)==true
			return @data[user]
		end
		userpath = File.join(@info[:path],user)
		Dir.chdir userpath
		games=Dir.entries('.').select{|e| e!='.' && e!='..'}
		games.map!{|item|
			size=getsize(File.join(userpath,item))
			{:icon=>File.join(userpath,item,'sce_sys','icon0.png'),
				:title=>gettitle(File.join(userpath,item,'sce_sys','param.sfo')),
				:id=>item,:size=>size[0],:patch=>size[1],:save=>size[2]}
		}
		return games
	end

	def getsize(path)
		allsize = (getfdsize(path) / (1024*1024)).to_i
		patch = 0
		if Dir.exist?(File.join(path,'patch'))
			patch = (getfdsize(File.join(path,'patch'))/ (1024*1024)).to_i
		end
		save = 0
		if Dir.exist?(File.join(path,'savedata'))
			save = (getfdsize(File.join(path,'savedata'))/1024).to_i
		end
		return [allsize,patch,save].map{|e|e.to_s}
	end

	def gettitle(path)
		conf=File.new(path, 'rb')
		conf.seek(632)
		data=[]
		conf.each_byte{|b| if b!=0 then data<<b; else break; end}
		return data.pack('C*').force_encoding('UTF-8')
	end

	def getfdsize(path)
		sum=0
		Dir.chdir path do
			Dir.entries('.').select{|e| e!='.' && e!='..'}.each{|f|
				fpath=File.join(path,f)
				if File.directory?(f)
					sum += getfdsize(fpath)
				else
					sum += File.size(fpath)
				end
			}
		end
		return sum
	end

end
