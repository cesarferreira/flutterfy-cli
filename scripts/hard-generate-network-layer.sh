# !/bin/bash

cd ../projects/automation/network_generator_flutter
./generate-network-layer.sh
rm -rf ../../lib/gen/swagger              # remove swagger folder
mv lib/gen/swagger/ ../../lib/gen/        # move everything