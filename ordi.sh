#!/bin/bash
# Use chmod +x funimp.sh if permission denied

# Recursively check all Swift files starting from ./
for file in `find . -type f -name \*.swift`; do
	echo "Checking $file"
	START_LINE=-1
	END_LINE=-1

	LINE_NUM=0

	# find all lines until a line that does not start with import / EOF is found
	while IFS='' read -r line || [[ -n "$line" ]]; do
		LINE_NUM=$((LINE_NUM + 1))
		echo $line | grep -q -m 1 -F -E "import "
		# check if import statement
		if [[ $? -eq 0 ]]; then
			# is an import statement
			if [[ $START_LINE -eq -1 ]]; then
				START_LINE=$LINE_NUM
				END_LINE=$LINE_NUM
			else
				END_LINE=$LINE_NUM
			fi
		fi
	done < $file

	echo $START_LINE, $END_LINE

	# if the lines exist, sort them
	if [[ $START_LINE -ne -1 ]]; then
		if [[ $START_LINE -gt 0 ]]; then
			head -n $((START_LINE-1)) $file > temp.txt
			if [[ $((END_LINE-START_LINE+1)) -gt 0 ]]; then
				tail -n +$((START_LINE)) $file | head -n $((END_LINE-START_LINE+1)) | sort >> temp.txt
			fi
			tail -n +$((END_LINE+1)) $file >> temp.txt
			mv temp.txt $file
		fi
	fi
done