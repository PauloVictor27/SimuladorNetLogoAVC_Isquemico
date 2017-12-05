extensions[bitmap]
breed [substancias substancia]
substancias-own [pN_or_pA]
patches-own [estado pintado]
;estado: 0 pra viva, 1 pra morta

globals [probabNecroApop resist lastx lasty]
;delayApop: Atraso da morte celular causa pela apoptose
;probabNecroApop: Probabilidade da celula morrer por necrose ou apoptose
;resist: Probabilidade a celula sobreviver ao contato de uma substancia nociva
;nInteracoes: Quantidade de interações realizadas no ambiente
;considere: sobrevivencia da celula + morte por necrose + morte por apoptose = 100%

;Função de Inicialização
to setup
  clear-all
  reset-ticks
  ask patches [
    set estado 0
    set pintado 0
  ]
  ;Importando tomografia
  ;import-pcolors "cranio.jpg"
  import-pcolors "cranio2.jpg"
  ;import-pcolors "cranio3.jpg"
  ;import-pcolors "cranio4.jpg"
  ;import-pcolors "cranio5.jpg"
  ;import-pcolors "cranio6.jpg"

  ;Atribuindo valores aos parametros
  set probabNecroApop 1.0 - probabNecro
  setup-plots
  file-open "LastCoords.txt"
  set lastx file-read
  set lasty file-read
  file-close
end

;Função que determina a morte celular instantanea
to pNecrose
  if ticks mod 1 = 0 [
    ;Interage com cada substancia sobre a célula que causa necrose
    ask substancias with[pN_or_pA >= probabNecroApop] [
      let atual self

      ;Altera o estado da célula atual
      ask patch-here[
        set estado 1
        if pintado = 0 [
          set pcolor (pcolor * 0.5)
          set pintado 1
        ]
      ]

      ;Seleciona os vizinhos
      ask neighbors with [estado = 0 and pcolor <= 8 and pxcor != 0 and pxcor != -1 and not any? substancias-here][
        let vizinhos self
        if pintado = 0[
          set pcolor (pcolor * 0.5)
          set pintado 1
        ]

        ask atual [
          ;Multiplica-se, gerando novas substancias
          hatch 1 [
            move-to vizinhos
            set pN_or_pA random-float 1
            ifelse pN_or_pA >= probabNecroApop[
              set color red ;Se a substancia causar necrose, ela será destacada de vermelho
            ][
              ifelse pN_or_pA < probabNecroApop and pN_or_pA >= probabResist[
                set color blue ;Se a substancia causar apoptose, ela será destacada de azul
              ][
                set color yellow ;Se a substancia não fizer nada, ela será destacada de amarelo
              ]
            ]
          ]
        ]
      ]
      die ;Descarta a substancia original
    ]
  ]
end

;Função que determina a morte celular com delay
to pApoptose
  if ticks mod delayApop = 0 [
    ;Interage com cada substancia sobre a célula que causa apoptose a cada n interações
    ask substancias with[pN_or_pA < probabNecroApop and pN_or_pA >= probabResist] [
      let atual self

      ;Altera o estado da célula atual
      ask patch-here[
        set estado 1
        if pintado = 0 [
          set pcolor (pcolor * 0.5)
          set pintado 1
        ]
      ]

      ;Seleciona os vizinhos
      ask neighbors with [estado = 0 and pcolor <= 8 and pxcor != 0 and pxcor != -1 and not any? substancias-here][
        let vizinhos self
        if pintado = 0 [
          set pcolor (pcolor * 0.5)
          set pintado 1
        ]

        ask atual [
          ;Multiplica-se, gerando novas substancias
          hatch 1 [
            move-to vizinhos
            set pN_or_pA random-float 1
            ifelse pN_or_pA >= probabNecroApop[
              set color red ;Se a substancia causar necrose, ela será destacada de vermelho
            ][
              ifelse pN_or_pA < probabNecroApop and pN_or_pA >= probabResist[
                set color blue ;Se a substancia causar apoptose, ela será destacada de azul
              ][
                set color yellow ;Se a substancia não fizer nada, ela será destacada de amarelo
              ]
            ]
          ]
        ]
      ]
      die ;Descarta a substancia Original
    ]
  ]
end

;Função que determina a resistencia celular
to pResist
  ;every 1 [
  if ticks mod 1 = 0[
    ask substancias with[pN_or_pA < probabResist] [
      die ;Se a célula resiste a subtancia, a subtancia morre em seguida
    ]
  ]
end

;Função para destacar a lesão com outra cor
to marcaVermelho
 ask patches with [estado = 1]
    [ set pcolor (pcolor + 10) ]
end

;Função para transformar o ambiente em uma imagem em preto e branco
to contraste
  ask patches with[pcolor <= tonalidade][
    set pcolor black
  ]
  ask patches with[pcolor > tonalidade][
    set pcolor white
  ]
  export-view "saidaconC"
end

;Função para executar nas ultimas coordenadas salvas
to go
  ;Condição de parada
  if ticks >= nInteracoes[
    stop
  ]

  ;Primeira Substancia
  if ticks = 0[
        create-substancias 1 [
          set heading 0
          set color red
          set shape "dot"
          set pN_or_pA 0.6
          set xcor mouse-xcor
          set ycor mouse-ycor
        ]
        set lastx mouse-xcor
        set lasty mouse-ycor
        file-delete "LastCoords.txt"
        file-open "LastCoords.txt"
        file-write lastx file-write lasty
        file-close
  ]

  ;Chamadas das mortes celulares
  pResist
  pApoptose
  pNecrose
  tick
end

;Função para executar em novas coordenadas
to go2
  ;Condição de parada
  if ticks >= nInteracoes[
    stop
  ]

  ;Primeira Substancia
  if ticks = 0[
        create-substancias 1 [
          set heading 0
          set color red
          set shape "dot"
          set pN_or_pA 0.6
          set xcor lastx
          set ycor lasty
        ]
  ]

  ;Chamadas das mortes celulares
  pResist
  pApoptose
  pNecrose
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
197
10
718
532
-1
-1
1.0
1
10
1
1
1
0
1
1
1
-256
256
-256
256
0
0
1
ticks
30.0

BUTTON
732
20
849
53
Inicializacao
setup
NIL
1
T
OBSERVER
NIL
I
NIL
NIL
1

BUTTON
731
59
849
100
Exe Nova
go
T
1
T
OBSERVER
NIL
E
NIL
NIL
1

BUTTON
859
20
962
53
Limpar
clear-turtles
NIL
1
T
OBSERVER
NIL
L
NIL
NIL
1

MONITOR
45
373
156
418
Celulas Vivas
count patches with [pcolor > 0.3 and pcolor < 8 and estado = 0] / 2\n;count patches with [pcolor > 0.3 and pcolor < 8 and estado = 0]
0
1
11

MONITOR
45
428
156
473
Celulas Mortas
count patches with[estado = 1]
17
1
11

MONITOR
9
18
94
63
coordX
mouse-xcor
0
1
11

MONITOR
9
73
98
118
coordY
mouse-ycor
0
1
11

SLIDER
6
142
182
175
nInteracoes
nInteracoes
0
300
60.0
1
1
NIL
HORIZONTAL

PLOT
728
166
1279
453
Grafico
Tempo
Quantidade
0.0
10.0
0.0
10.0
true
true
";plot count patches with [pcolor > 0.3 and pcolor < 8 and estado = 0]" ""
PENS
"Celulas Vivas" 1.0 0 -13345367 true "plot-pen-reset\nplot-pen-up\nplot count patches with [pcolor > 0.3 and pcolor < 8 and estado = 0] / 2\n;plot count patches with [pcolor > 0.3 and pcolor < 8 and estado = 0]\nplot-pen-down" "plot count patches with [pcolor > 0.3 and pcolor < 8 and estado = 0] / 2\n;plot count patches with [pcolor > 0.3 and pcolor < 8 and estado = 0]"
"Celulas Mortas" 1.0 0 -2674135 true "" "plot count patches with[estado = 1]"

BUTTON
732
108
847
146
Salvar
export-view \"saidaC\"
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
855
109
967
147
Contraste
contraste
NIL
1
T
OBSERVER
NIL
C
NIL
NIL
1

MONITOR
123
18
180
63
LastX
lastx
0
1
11

MONITOR
123
74
180
119
LastY
lasty
0
1
11

BUTTON
857
61
964
100
Exe Ultima
go2
T
1
T
OBSERVER
NIL
U
NIL
NIL
0

SLIDER
6
183
183
216
tonalidade
tonalidade
0
9.9
2.6
0.1
1
NIL
HORIZONTAL

SLIDER
6
224
183
257
delayApop
delayApop
1
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
4
265
185
298
probabNecro
probabNecro
probabResist
1.0
0.4
0.025
1
NIL
HORIZONTAL

SLIDER
3
308
185
341
probabResist
probabResist
0.0
probabNecro - 0.05
0.25
0.025
1
NIL
HORIZONTAL

BUTTON
971
21
1072
55
Colorir
marcaVermelho
NIL
1
T
OBSERVER
NIL
M
NIL
NIL
1

@#$#@#$#@
## O que é?

Um simulador do AVC isquêmico, onde dada uma tomografia ele gera uma lesão na área indicada. Indicando com uma cor mais escura.

## Como funciona:

Cada pixel cinza da tomografia passada pelo simulador representa uma célula. Cada célula pode morre por necrose(morte instantanea), por apoptose(morte com delay) ou até mesmo resistir ao ataque. Conforme as configurações dos parâmetros ao lado do ambiente. nInterações determina quantas interações terá em uma execução, influenciando no tamanho da lesão. tonalidade altera o contraste da tomografia quando apertado o botão C para gerar uma imagem em preto e branco sem tons de cinza. ProbabNecro e ProbabResist determinam a probabilidade de necrose e resistencia celular respectivamente, a ocorrencia de apoptose é complementar das duas propabilidades. delayApop define quantas interações terá o delay da Apoptose

## Como utiliza-lo:

Precione o botão I para carregar a tomografia do paciente, sendo ela passada na codificação da função setup. Possicione o mouse na região onde deseja simular a lesão e prescione o botão E para começar a simulação. Utilize o botão U para refazer a ultimia execução. Use o botão S para salvar a imagem gerada e o botão M para mudar a cor da lesão.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
