#!bin/bash
########################################
#                免责声明
#    本脚本仅用于个人学习、研究使用等
#   禁止一切用于商业或盈利性为目的用途
# 通过使用本脚本带来的所有风险与作者无关
#   应遵守著作权法及其他相关法律的规定
#         下载后请在24小时内删除
#    使用者使用本脚本默认同意上述约定
########################################
#      特别感谢 @浅错觉 给予的帮助
########################################
#        已集成自动安装依赖功能
#  apt install vim gawk grep jq ffmpeg
########################################
#脚本版本
echo -e "\033[1;36m本脚本版本为 v5.0\033[0m"
#定义bilibili输出目录
output_dir="/storage/emulated/0/Video/"
if [ ! -d "$output_dir" ]; then
  echo -e "\033[1;32m创建输出目录:\033[0m\033[1;31m$output_dir\033[0m"
  mkdir $output_dir
else
  echo -e "\033[1;32m输出目录:\033[0m\033[1;31m$output_dir\033[0m"
fi
#允许访问内部储存
if [ $PREFIX == /data/data/com.termux/files/usr ]; then
  termux-setup-storage
fi
#安装相关依赖
autoCheck() {
  echo -e "\033[1;31m检查是否缺失依赖...\033[0m"
  if [ ! -f $PREFIX/bin/vim ] || [ ! -f $PREFIX/bin/awk ] || [ ! -f $PREFIX/bin/sed ] || [ ! -f $PREFIX/bin/grep ] || [ ! -f $PREFIX/bin/jq ] || [ ! -f $PREFIX/bin/ffmpeg ]; then
	echo -e "\033[1;31m正在安装相关依赖...\033[0m"
	apt install vim gawk sed grep jq ffmpeg -y
	if [ -f $PREFIX/bin/vim ] || [ -f $PREFIX/bin/awk ] || [ -f $PREFIX/bin/sed ] || [ -f $PREFIX/bin/grep ] || [ -f $PREFIX/bin/jq ] || [ -f $PREFIX/bin/ffmpeg ]; then
	  echo -e "\033[1;31m所需依赖安装完毕\033[0m"
	else
	  echo -e "\033[1;31m所需依赖安装不成功\033[0m"
	  echo -e "https://zhuanlan.zhihu.com/p/109791630"
	  echo -e "\033[1;31m打开上面链接,截图将问题反馈给我吧\033[0m"
	fi
  else
	echo -e "\033[1;31m没有依赖缺失...\033[0m"
  fi
}
#遍历各bilibili版本缓存目录
checkApp() {
  for bili in tv.danmaku.bili com.bilibili.app.in com.bilibili.app.blue
  do
	#判断各bilibili是否有缓存
	if [ -d "/storage/emulated/0/Android/data/$bili/download/" ]; then
	  #定义bilibili缓存目录
	  bili_dir="/storage/emulated/0/Android/data/$bili/download/"
	  #获取bilibili缓存目录
	  cache_dir+=$(ls $bili_dir)
	  cache_dir+=" "
	  #获取各哔哩哔哩中的缓存数
	  if [ $bili = "tv.danmaku.bili" ]; then
		tv=`echo $(ls $bili_dir) | awk '{print NF}'`
	  elif [ $bili = "com.bilibili.app.in" ]; then
		#in=`echo $(ls $bili_dir) | awk '{print NF}'`
		in=`echo $cache_dir | awk '{print NF}'`
	  elif [ $bili = "com.bilibili.app.blue" ]; then
		#blue=`echo $(ls $bili_dir) | awk '{print NF}'`
		blue=`echo $cache_dir | awk '{print NF}'`
	  fi
	  echo -e "\t\033[1;35m检测到 $bili 中有缓存\033[0m"
	  #echo $cache_dir | awk '{print NF}'
	  #echo $in
	else
	  echo -e "\t\033[1;34m检测到 $bili 中没有缓存\033[0m"
	fi
  done
}
#定义一组数组
Array[0]=0 #bilibili缓存目录数
Array[1]=0 #读取 $blv_file 字段数
Array[2]=0 #读取 $cache_dir 字段数
#let Array[0]++
#echo `let Array[0]++`
#输出bilibili缓存目录
look_dir() {
  i=0
  title_dir="\t\033[1;35m$((i++)):\033[0m\033[1;35m全部输出\033[0m"
  for cache in $cache_dir; do
	if [ $i -le $tv ]; then
	  bili="tv.danmaku.bili"
	elif [ $i -gt $tv ] && [ $i -le $in ]; then
	  bili="com.bilibili.app.in"
	elif [ $i -gt $in ] && [ $i -le $blue ]; then
	  bili="com.bilibili.app.blue"
	fi
	#定义bilibili缓存目录
	bili_dir="/storage/emulated/0/Android/data/$bili/download/"
    video_dir=$(ls $bili_dir$cache)
    video1=`echo $video_dir | awk '{print $1}'`
	#echo $bili_dir
    title=`jq -r '.title' $bili_dir$cache/$video1/entry.json`
    title=${title//[[:space:]]/_}
    title_dir+="\n\t\033[1;35m$((i++)):\033[0m\033[1;37m$title\033[0m"
  done
  title_dir+="\n\t\033[1;35m*:\033[0m\033[1;31m按回车键退出\033[0m"
  Array[0]=$i
  echo -e $title_dir
}
#输入一个数字
read_n() {
  read -p "`echo -e "\033[1;32m请选择一个视频:\033[0m"`" id
  to_Process(){
	if [ $id -le $tv ]; then
	  bili="tv.danmaku.bili"
	elif [ $id -gt $tv ] && [ $id -le $in ]; then
	  bili="com.bilibili.app.in"
	elif [ $id -gt $in ] && [ $id -le $blue ]; then
	  bili="com.bilibili.app.blue"
	fi
	#定义bilibili缓存目录
	bili_dir="/storage/emulated/0/Android/data/$bili/download/"
	cache=`echo $cache_dir | awk -v i=$id '{print $i}'`
	video_dir=$(ls $bili_dir$cache)
	video1=`echo $video_dir | awk '{print $1}'`
	title=`jq -r '.title' $bili_dir$cache/$video1/entry.json`
	title=${title//[[:space:]]/_}
	title=${title////_}
	#创建视频分类目录
	if [ ! -d "$output_dir$title/" ]; then
	  echo -e "\033[1;32m创建目录:\033[0m\033[1;31m$title\033[0m"
	  mkdir $output_dir$title
	else
	  echo -e "\033[1;32m目录:\033[0m\033[1;31m$title\033[0m\033[1;32m已存在\033[0m"
	fi
	#视频输出处理
	for video in $video_dir; do
	  #判断视频类型
	  if [[ $cache == s* ]]; then
		echo -e "\t\033[1;37m视频类型:番剧\033[0m"
		#获取索引
		index=`jq -r '.ep.index' $bili_dir$cache/$video/entry.json`
		#获取标题
		index_title=`jq -r '.ep.index_title' $bili_dir$cache/$video/entry.json`
		#传参
		_index=$index
		_title=$index_title
		#判断$index是否小于10
		if [ $_index -lt 10 ]; then
		  _index=0$_index
		fi
		#输出命名格式
		name=第$_index话『$_title』.mp4
	  else
		echo -e "\t\033[1;37m视频类型:肥皂剧\033[0m"
		#获取索引
		page=`jq -r '.page_data.page' $bili_dir$cache/$video/entry.json`
		#获取标题
		part=`jq -r '.page_data.part' $bili_dir$cache/$video/entry.json`
		#传参
		_index=$page
		_title=$part
		#输出命名格式
		name=$_title.mp4
	  fi
	  #获取下级缓存目录
	  type_tag=`jq -r '.type_tag' $bili_dir$cache/$video/entry.json`
	  #筛选后缀为 .blv 的文件
	  blv_file=$(ls $bili_dir$cache/$video/$type_tag | grep ".blv")
	  #读取 $blv_file 字段数
	  Array[1]=`echo $blv_file | awk '{print NF}'`
	  #特殊字符过滤
	  name=${name//[[:space:]]/_}
	  name=${name////_}
	  #判断是否输出过
	  if [ ! -f $output_dir$title/$name ]; then
		echo -e "\t\033[1;32m输出第\033[0m\033[1;31m$_index\033[0m\033[1;32m个视频\033[0m"
		#判断后缀是.m4s还是.blv
		if [ -f $bili_dir$cache/$video/$type_tag/video.m4s ]; then
		  ffmpeg -i $bili_dir$cache/$video/$type_tag/video.m4s -i $bili_dir$cache/$video/*/audio.m4s -c copy $output_dir$title/$name
		else
		  if [ ${Array[1]} -eq 1 ]; then
			ffmpeg -i $bili_dir$cache/$video/$type_tag/0.blv -c copy $output_dir$title/$name
		  else
			#指定 ffmpeg-concat 所需的文件
			filelist="$bili_dir$cache/$video/$type_tag/filelist.txt"
			#制作 ffmpeg-concat 所需合并清单
			for blv in $blv_file; do
			  echo "file '$blv'" >> $filelist
			done
			ffmpeg -f concat -i $bili_dir$cache/$video/$type_tag/filelist.txt -c copy $output_dir$title/$name
			rm -rf $filelist
		  fi
		fi
		#检查是否成功
		if [ -f $output_dir$title/$name ]; then
		  echo -e "\t\033[1;32m视频\033[0m\033[1;31m$name\033[0m\033[1;32m合成完成\033[0m"
		else
		  echo -e "\t\033[1;32m注意:合成\033[0m\033[1;31m$name\033[0m\033[1;32m未成功\033[0m"
		fi
	  else
		echo -e "\t\033[1;31m$name\033[0m\033[1;32m已存在\033[0m"
	  fi
	done
  }
  case $id in
    0)
      echo -e "\033[1;31m还没有开发哦😊\033[0m"
	  ;;
    [[:digit:]]*)
	  if [ $id -lt ${Array[0]} ]; then
		to_Process
	  else
		echo -e "\033[1;31m没有你要的操作，请重新选择吧！\033[0m"
	  fi
	  ;;
    *)
      echo -e "\033[1;31mExit\033[0m"
      exit
  esac
}
#运行脚本
autoCheck
checkApp
for((;;))
do
  look_dir
  read_n
done
