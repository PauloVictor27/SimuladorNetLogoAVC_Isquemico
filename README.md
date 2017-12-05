# SimuladorNetLogoAVC_Isquemico
Um simulador do AVC isquêmico com o uso da ferramenta NetLogo, onde dada uma tomografia ele gera uma lesão na área indicada. Indicando com uma cor mais escura.

# Como utiliza-lo:

Inicialmente, tenha a ferramenta NetLogo instalada em seu computador. Depois da instalação, abra o arquivo SimuladorOficial.nlogo usando a ferramenta para carregar o ambiente. Precione o botão I para carregar a tomografia do paciente, sendo ela passada na codificação da função setup. Possicione o mouse na região onde deseja simular a lesão e prescione o botão E para começar a simulação. Utilize o botão U para refazer a ultimia execução. Use o botão S para salvar a imagem gerada e o botão M para mudar a cor da lesão.

# Como funciona:

Cada pixel cinza da tomografia passada pelo simulador representa uma célula. Cada célula pode morre por necrose(morte instantanea), por apoptose(morte com delay) ou até mesmo resistir ao ataque. Conforme as configurações dos parâmetros ao lado do ambiente. nInterações determina quantas interações terá em uma execução, influenciando no tamanho da lesão. tonalidade altera o contraste da tomografia quando apertado o botão C para gerar uma imagem em preto e branco sem tons de cinza. ProbabNecro e ProbabResist determinam a probabilidade de necrose e resistencia celular respectivamente, a ocorrencia de apoptose é complementar das duas propabilidades. delayApop define quantas interações terá o delay da Apoptose
