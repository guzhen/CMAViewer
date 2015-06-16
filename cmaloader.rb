class CMAApp
	FOLDERS=["app","appmeta","license","patch","savedata","sce_sys",]
	PATH='APP'

	def initialize
		@info={'path'=>'','user'=>[]}
		@data={}
	end

	def load(path)
		apppath = File.join(path,PATH)
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
		return [1000,200,3000].map{|e|e.to_s}
	end

	def gettitle(path)
		return 'some title'
	end
end
