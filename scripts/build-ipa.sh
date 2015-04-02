#!/bin/bash

#
# ビルドしてipaファイルを作成する
#

declare -r SCRIPT_NAME=${0##*/}

# TODO : XCODE_PROJECTにも対応する
print_usage()
{
    cat << EOF
Usage: $SCRIPT_NAME [-o OUTPUT_PATH] [-c CONFIGURATION] [-m PROVISIONING_FILE_DIR] -d DEVELOPER_NAME -a APPNAME -p PROVISIONING_FILE -s XCODE_SCHEME -w XCODE_WORKSPACE

Build iOS project and create ipa file.

  -o OUTPUT_PATH        Output path (default: \$PWD/build)
  -c CONFIGURATION      Build configuration (default: Release)
  -d DEVELOPER_NAME     Identity in Keychanin
  -a APPNAME            iOS application name
  -p PROVISIONING_FILE  mobileprovision file name
  -m PROVISIONING_FILE_DIR mobileprovision file directory (default: \$HOME/Library/MobileDevice/Provisioning Profiles)
  -s XCODE_SCHEME       Xcode scheme(build target name)
  -w XCODE_WORKSPACE    Xcode workspace name
  -h                    display this help and exit

Examples
  $SCRIPT_NAME -o \$PWD/build -d "iPhone Distribution: FaithCreates Inc." -a CircleCI-Sample -p 6d7927d4-5e5d-4d32-b4bc-742251de4e51.mobileprovision -s CircleCI-Sample -w CircleCI-Sample.xcworkspace
EOF
}

print_error()
{
    echo "$SCRIPT_NAME: $*" 1>&2
    echo "Try \`-h' option for more information." 1>&2
}

main()
{
    local output_path="$PWD/build"
    local developer_name=''
    local appname=''
    local provisioning_file=''
    local provisioning_file_dir="$HOME/Library/MobileDevice/Provisioning Profiles"
    local xcode_scheme=''
    local xcode_workspace=''
    local configuration='Release'

    local option
    local OPTARG
    local OPTIND
    while getopts ':o:c:d:a:p:m:s:w:h' option; do
        case $option in
        o)
            output_path=$OPTARG
            ;;
        c)
            configuration=$OPTARG
            ;;
        d)
            developer_name=$OPTARG
            ;;
        a)
            appname=$OPTARG
            ;;
        p)
            provisioning_file=$OPTARG
            ;;
        m)
            provisioning_file_dir=$OPTARG
            ;;
        s)
            xcode_scheme=$OPTARG
            ;;
        w)
            xcode_workspace=$OPTARG
            ;;
        h)
            print_usage
            return 0
            ;;
        :)  #オプション引数欠如
            print_error "option requires an argument -- $OPTARG"
            return 1
            ;;
        *)  #不明なオプション
            print_error "invalid option -- $OPTARG"
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ -z "$output_path" ]; then
        print_error 'you must specify output_path'
        return 1
    fi

    if [ -z "$configuration" ]; then
        print_error 'you must specify configuration'
        return 1
    fi

    if [ -z "$developer_name" ]; then
        print_error 'you must specify developer_name'
        return 1
    fi

    if [ -z "$appname" ]; then
        print_error 'you must specify appname'
        return 1
    fi

    if [ -z "$provisioning_file" ]; then
        print_error 'you must specify provisioning_file'
        return 1
    fi

    if [ -z "$provisioning_file_dir" ]; then
        print_error 'you must specify provisioning_file_dir'
        return 1
    fi

    if [ -z "$xcode_scheme" ]; then
        print_error 'you must specify xcode_scheme'
        return 1
    fi

    if [ -z "$xcode_workspace" ]; then
        print_error 'you must specify xcode_workspace'
        return 1
    fi

    # 末尾の/を取り除きます
    # ただし、"/"である場合はそのままとします
    if [ "$provisioning_file_dir" != "/" ]; then
        provisioning_file_dir="${provisioning_file_dir%/}"
    fi

    local provisioning_profile_path="${provisioning_file_dir}/$provisioning_file"

    # Archive
    xcodebuild \
      -scheme "$xcode_scheme" \
      -workspace "$xcode_workspace" \
      -configuration "$configuration" \
      clean build \
      CODE_SIGN_IDENTITY="$developer_name" \
      CONFIGURATION_BUILD_DIR="$output_path" \

    # Signing
    xcrun -log -sdk iphoneos PackageApplication \
      "${output_path}/${appname}.app" \
      -o "${output_path}/${appname}.ipa" \
      -sign "$developer_name" \
      -embed "$provisioning_profile_path"

    # 作成したipaファイルのパス = ${output_path}/${appname}.ipa
}

main "$@"

