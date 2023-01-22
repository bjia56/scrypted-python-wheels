#!/bin/bash
# adapted from https://gist.github.com/lunhg/6cc9f4642aee8a8a1151288e6a522e38
set -x

PACKAGE=$1
NEW_VERSION=$2
WHEEL=$3

TEMPDIR=$(mktemp -d)

cp $WHEEL $TEMPDIR/
cd $TEMPDIR

python3 -m virtualenv venv && source venv/bin/activate


python3 -m wheel unpack $WHEEL
rm $WHEEL
WHEEL_FOLDER=$(ls -la | awk '{ print $9 }' | grep $PACKAGE)
mkdir $PACKAGE-$NEW_VERSION
mkdir $PACKAGE-$NEW_VERSION/$PACKAGE
mkdir $PACKAGE-$NEW_VERSION/$PACKAGE-$NEW_VERSION.dist-info
cp $WHEEL_FOLDER/$WHEEL_FOLDER.dist-info/* $PACKAGE-$NEW_VERSION/$PACKAGE-$NEW_VERSION.dist-info/
cp -r $WHEEL_FOLDER/$PACKAGE $PACKAGE-$NEW_VERSION
CURRENT_VERSION=`cat $WHEEL_FOLDER/$WHEEL_FOLDER.dist-info/METADATA | grep ^Version | cut -d ' ' -f2`
echo $CURRENT_VERSION
sed -i 's/'$CURRENT_VERSION'$/'$NEW_VERSION'/g' $PACKAGE-$NEW_VERSION/$PACKAGE-$NEW_VERSION.dist-info/METADATA
rm $PACKAGE-$NEW_VERSION/$PACKAGE-$NEW_VERSION.dist-info/RECORD
python3 -m wheel pack $PACKAGE-$NEW_VERSION
NEW_WHEEL=$(ls -la $PACKAGE*.whl | awk '{ print $9 }')
python3 -m pip install $NEW_WHEEL
python3 -m pip list

cd -
cp $TEMPDIR/$NEW_WHEEL .

deactivate
rm -rf $TEMPDIR