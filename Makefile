server:
	bundle exec puma

todo:
	grep -Rin --include="*.rb" "TODO" *
