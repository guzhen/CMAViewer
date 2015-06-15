class CMAApp
	FOLDERS=["app","appmeta","license","patch","savedata","sce_sys",]
	PATH='APP'

	def initialize
		@info={'path'=>'','user'=>[]}
		@data={}
	end

	def load(path)
		begin
			Dir.chdir path do
				@info[:path]=path
				Dir.chdir PATH
				@info[:user]=Dir.entries.select{|e| e!='.' && e!='..'}
				return @info[:user]
			end
		rescue
			return nil
		end
	end

	def select(user)
		if !@info[:user].include?(user)
			return nil
		end
		if @data[user]!=nil
			return @data[user]
		end
		begin
			Dir.chdir @info[path]
		rescue
			return nil
		end
	end
end
