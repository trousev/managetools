which node 1> /dev/null 2> /dev/null

if [ $? = 1 ]; then
    alias node=nodejs
fi
for i in /opt/npm-local-registry/*; do 
    __path=$i/node_modules/.bin
    if [ -d $__path ]; then
        export PATH=$PATH:$__path
    fi
done
