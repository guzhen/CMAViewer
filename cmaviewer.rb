require 'qt'

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

class UIApp<Qt::Widget

	def initialize
		super
		init_ui
		@control=CMAApp.new
	end

	WIDTH = 400
	HIGHT = 400
	@ui
	def init_ui
		@ui={}
		## upside
		label_path = Qt::Label.new "CMA Path:",self
		label_path.resize 50,20
		label_path.move 10,10
		@ui['label_path']=label_path
		lineEdit_path = Qt::LineEdit.new self
		lineEdit_path.resize 200,20
		lineEdit_path.move 70,10
		@ui['lineEdit_path']=lineEdit_path
		label_user = Qt::Label.new "User ID:",self
		label_user.resize 50,20
		label_user.move 10,40
		@ui['label_user']=label_user
		comboBox_user = Qt::ComboBox.new self
		comboBox_user.resize 200,20
		comboBox_user.move 70,40
		comboBox_user.setDisabled true
		@ui['comboBox_user']=comboBox_user
		pushButton_load = Qt::PushButton.new "Read\nPath",self
		pushButton_load.resize 60,50
		pushButton_load.move 280,10
		@ui['pushButton_load']=pushButton_load
		pushButton_user = Qt::PushButton.new "Load\nUser",self
		pushButton_user.resize 60,50
		pushButton_user.move 340,10
		@ui['pushButton_user']=pushButton_user
		## downside
		scrollArea = Qt::ScrollArea.new self
		scrollArea.resize 380,320
		scrollArea.move 10,70
		@ui['scrollArea']=scrollArea
		## main
		connect pushButton_load,SIGNAL('clicked()'),self,SLOT('onLoad()')
		connect pushButton_user,SIGNAL('clicked()'),self,SLOT('onUser()')
		signalMapper = Qt::SignalMapper.new self
		connect signalMapper,SIGNAL('mapped(QString)'),self,SLOT('onClick(QString)')
		@ui['signalMapper']=signalMapper
		resize WIDTH,HIGHT
		setMinimumSize WIDTH,HIGHT
		setMaximumSize WIDTH,HIGHT
		setWindowTitle 'CMA Viewer'
		show
	end

	################################
	#	slots
	slots 'onLoad()','onUser()','onClick(QString)'
	def onLoad
		#testgen @ui['lineEdit_path'].text.to_i
		users = @control.load(@ui['lineEdit_path'].text)
		users.each{|user| @ui['comboBox_user'].addItem(user)}
		if users.length == 1
			onUser
		elsif users.length > 1
			@ui['comboBox_user'].setDisabled false
		else
			openmsg "path error!\nCan not get user ID!"
		end
	end
	def onUser
		datas = @control.select @ui['comboBox_user'].currentText
		if datas.length <= 0
			openmsg "Nothing in the path!"
		end
		genlist datas
	end
	def onClick(i)
		p 'button '+i+' clicked'
	end

	################################
	#	functions
	def openmsg(msg,level=1)
		Qt::MessageBox.information(nil, 'Message',msg)
	end

	def genlist(items)
		if items.class != Array || items.length > 2000
			openmsg 'data error!'
		end
		screen = Qt::Widget.new self
		basex=10;basey=10;
		items.each_with_index{|item,index|
			if item.class == Hash
				icon = Qt::Pixmap.new item[:icon]
				icon_label = Qt::Label.new screen
				icon_label.setPixmap icon
				icon_label.resize 128,128
				icon_label.move basex, basey
				label_id = Qt::Label.new item[:id],screen
				label_id.resize 100,20
				label_id.move basex+130+10,basey
				label_size = Qt::Label.new 'Size:',screen
				label_size.resize 50,20
				label_size.move basex+130+10,basey+30
				label_size_mb = Qt::Label.new item[:size]+' MB',screen
				label_size_mb.resize 50,20
				label_size_mb.move basex+130+10+50,basey+30
				button_delete = Qt::PushButton.new 'delete game',screen
				button_delete.resize 100,20
				button_delete.move basex+130+10+50+50,basey+30
				connect button_delete,SIGNAL('clicked()'),@ui['signalMapper'],SLOT('map()')
				@ui['signalMapper'].setMapping button_delete,[index,'game'].join("\n")
				label_patch = Qt::Label.new 'Patch:',screen
				label_patch.resize 50,20
				label_patch.move basex+130+10,basey+60
				label_patch_size = Qt::Label.new item[:patch]+'MB',screen
				label_patch_size.resize 50,20
				label_patch_size.move basex+130+10+50,basey+60
				button_delete_patch = Qt::PushButton.new 'delete patch',screen
				button_delete_patch.resize 100,20
				button_delete_patch.move basex+130+10+50+50,basey+60
				connect button_delete_patch,SIGNAL('clicked()'),@ui['signalMapper'],SLOT('map()')
				@ui['signalMapper'].setMapping button_delete_patch,[index,'patch'].join("\n")
				if item[:patch] == '0'
					button_delete_patch.setDisabled true
				end
				label_save = Qt::Label.new 'Save:',screen
				label_save.resize 50,20
				label_save.move basex+130+10,basey+90
				label_save_size = Qt::Label.new item[:save]+'KB',screen
				label_save_size.resize 50,20
				label_save_size.move basex+130+10+50,basey+90
				button_delete_save = Qt::PushButton.new 'delete save',screen
				button_delete_save.resize 100,20
				button_delete_save.move basex+130+10+50+50,basey+90
				connect button_delete_save,SIGNAL('clicked()'),@ui['signalMapper'],SLOT('map()')
				@ui['signalMapper'].setMapping button_delete_save,[index,'save'].join("\n")
				if item[:save] == '0'
					button_delete_save.setDisabled true
				end
				basey+=130
			end
		}
		screen.resize basex+350,basey
		screen.show
		@ui['scrollArea'].setWidget screen
	end
end

app = Qt::Application.new ARGV
UIApp.new
app.exec
