#список дисков
get-disk
#список разделов
get-partition
#увеличим до максимального размера раздел 1 диска 0
$hashargs = @{
  disknumber = 0 
  partitionnumber = 1
}
$size = (Get-PartitionSupportedSize @hashargs)
resize-partition @hashargs -size $size.SizeMax
