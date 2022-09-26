MODULE=$1
TEST_DIR=$2
cp build/$1/approval.teal tests/assets
cp build/$1/clear.teal tests/assets
cd tests && npx mocha -r ts-node/register "src/$2"