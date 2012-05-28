#!/bin/sh

install_resource()
{
  case $1 in
    *.xib)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib ${SRCROOT}/Pods/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib ${SRCROOT}/Pods/$1 --sdk ${SDKROOT}
      ;;
    *)
      echo "cp -R ${SRCROOT}/Pods/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      cp -R "${SRCROOT}/Pods/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      ;;
  esac
}
install_resource 'DLStarRating/DLStarRating/images/star.png'
install_resource 'DLStarRating/DLStarRating/images/star@2x.png'
install_resource 'DLStarRating/DLStarRating/images/star_highlighted-darker.png'
install_resource 'DLStarRating/DLStarRating/images/star_highlighted-darker@2x.png'
install_resource 'DLStarRating/DLStarRating/images/star_highlighted.png'
install_resource 'DLStarRating/DLStarRating/images/star_highlighted@2x.png'
