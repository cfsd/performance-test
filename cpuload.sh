cmd=$1
delay=5
loops=$[300/$delay]
folder="$(date "+%Y%m%d-%H%M")"
mkdir "$folder" 2>/dev/null
image="$(docker ps --filter "name=$cmd" --format '{{.Image}}')"
container="$(docker ps --filter "name=$cmd" --format '{{.Names}}')"
pid="$(docker inspect -f '{{.State.Pid}}' $container)"

file="$folder/$cmd.cpu"
file2="$folder/$cmd.mem"

date | tee -a $file $file2;

ps -p $pid -o cmd= | tee -a $file $file2;
echo "image=$image" | tee -a $file $file2
echo "name=$cmd" | tee -a $file $file2
echo "Start of logging" | tee -a $file $file2
for i in `seq 1 $loops`; do
         ps -p $pid -o %cpu= | tee -a $file;
         ps -p $pid -o %mem= | tee -a $file2;
         sleep $delay;
done

echo "End of logging" | tee -a $file $file2

python3 plot.py 1 $folder
python3 plot.py 2 $folder