!pip install git+https://github.com/aliutkus/torchinterp1d.git
!pip install git+https://github.com/thissop/spender.git
!git clone https://github.com/thissop/spender.git

import shutil

shutil.copyfile('/content/sky-lines.txt', '/usr/local/lib/python3.10/dist-packages/spender/data/sky-lines.txt')

!cd /usr/local/lib/python3.10/dist-packages/spender/data/; ls