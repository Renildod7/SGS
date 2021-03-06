:- module(util,[
    limpaTela/0,
    pausa1/0,
    pausa2/0,
    pausa5/0,
    getNomeCliente/2,
    lerEntrada/1,
    lerEntradaNum/1,
    lerCategoria/1,
    splitEspaco/2,
    geraCliente/6,
    geraProfissional/6,
    geraServico/6,
    geraAtendimentoPendente/4,
    listaCategorias/1,
    getTodosServicos/1,
    listarServicos/2,
    getCategorias/1,
    verificaPreco/1,
    getServicosCategoria/2,
    getDoisMelhorAvaliados/2,
    getAtPendentesProfissional/2,
    listarAtPendentesProfissional/2,
    geraRetractAtPendente/2,
    geraAtAceito/2,
    geraAtRecusado/2,
    getAtAceitosCliente/2,
    listarAtAceitosCliente/2,
    geraRetractAtAceito/2,
    geraAtendimentoConcluitdo/3,
    ordenaServicosAvaliacao/2,
    getFaturamentoProfissional/2,
    getServicosContratadosClientePendentes/2,
    getServicosContratadosClienteAceitos/2,
    getServicosContratadosClienteRecusados/2,
    listaAtNaoCloncluidoCliente/2,
    getServicosContratadosClienteConcluidos/2,
    listaAtCloncluidoCliente/2
    ]).

limpaTela:-
    tty_clear.

pausa1 :-
    sleep(1).

pausa2 :-
    sleep(2).

pausa5 :-
    sleep(5).

getNomeCliente(EmailC,NomeC):-
    cliente(EmailC,_,NomeC,_,_).

listaCategorias([]).
listaCategorias([H|T]):- writeln(H), listaCategorias(T).

lerCategoria(Entrada):-
    read_line_to_codes(user_input,Entradaascii),
    string_to_atom(Entradaascii,Entrada).


lerEntrada(Entrada):-
    read_line_to_codes(user_input,Entradaascii),
    string_to_atom(Entradaascii,EntradaString),
    string_lower(EntradaString,Entrada).

lerEntradaNum(EntradaNum):-
    read_line_to_codes(user_input,Entradaascii),
    string_to_atom(Entradaascii,EntradaString),
    atom_number(EntradaString,EntradaNum).

verificaPreco(Preco):- integer(Preco);float(Preco).

splitEspaco(String,Lista):- 
    split_string(String," ","\s\t\n",Lista).

geraCliente(Nome,Email,Senha,Endereco,Telefone,NovoCliente):-
    string_concat("cliente(",Email,X1),
    string_concat(X1,",",X2),
    string_concat(X2,Senha,X3),
    string_concat(X3,",",X4),
    string_concat(X4,Nome,X5),
    string_concat(X5,",",X6),
    string_concat(X6,Endereco,X7),
    string_concat(X7,",",X8),
    string_concat(X8,Telefone,X9),
    string_concat(X9,").",NovoCliente).

geraProfissional(Nome,Email,Senha,Endereco,Telefone,NovoProfissonal):-
    string_concat("profissional(",Email,X1),
    string_concat(X1,",",X2),
    string_concat(X2,Senha,X3),
    string_concat(X3,",",X4),
    string_concat(X4,Nome,X5),
    string_concat(X5,",",X6),
    string_concat(X6,Endereco,X7),
    string_concat(X7,",",X8),
    string_concat(X8,Telefone,X9),
    string_concat(X9,").",NovoProfissonal).


geraServico(Categoria,Descricao,Preco,EmailP,NomeP,NovoServico):-
    string_concat("servico(",Categoria,X1),
    string_concat(X1,",[",X2),
    string_concat(X2,Descricao,X3),
    string_concat(X3,"],",X4),
    string_concat(X4,Preco,X5),
    string_concat(X5,",",X6),
    string_concat(X6,EmailP,X7),
    string_concat(X7,",",X8),
    string_concat(X8,NomeP,X9),
    string_concat(X9,").",NovoServico).


somaAvaliacoes([],0).
somaAvaliacoes([[H|_]|T],R):- somaAvaliacoes(T,G), R is H+G.

adiciona(X,Y,[X|Y]).

getTodosServicos(R):-getTodosServicosAux([],R),!.

getTodosServicosAux(Lista,R):-
    L = [],
    main:servico(Categoria,Descricao,Preco,EmailP,NomeP),
    adiciona(NomeP,L,L2),
    adiciona(EmailP,L2,L3),
    adiciona(Preco,L3,L4),
    adiciona(Descricao,L4,L5),
    adiciona(Categoria,L5,L6),

    \+ member(L6,Lista),
    adiciona(L6,Lista,Lista2),
    getTodosServicosAux(Lista2,R);
    R = Lista.

getAvaliacoes(Categoria,Descricao,Preco,EmailP,NomeP,R):-
    getAvaliacoesAux(Categoria,Descricao,Preco,EmailP,NomeP,[],R),!.

getAvaliacoesAux(Categoria,Descricao,Preco,EmailP,NomeP,Lista,R):-
    L = [],
    main:atConcluido(_,_,Categoria,Descricao,Preco,EmailP,NomeP,Avaliacao,Num),
    adiciona(Num,L,L2),
    adiciona(Avaliacao,L2,L3),
    \+ member(L3,Lista),
    adiciona(L3,Lista,Lista2),
    getAvaliacoesAux(Categoria,Descricao,Preco,EmailP,NomeP,Lista2,R);
    R = Lista.

listarServicos(ListaServicos,R):- listarServicosAux(ListaServicos,"",1,R).

listarServicosAux([],String,_,R):- R = String,!.
listarServicosAux([H|T],String,N,R):-
    getAtributosServico(H,Categoria,Descricao,Preco,EmailP,NomeP),
    getAvaliacoes(Categoria,Descricao,Preco,EmailP,NomeP,AvaliacoesL),
    somaAvaliacoes(AvaliacoesL,SomaAvali),
    length(AvaliacoesL,QtdAvali),
    QtdAvali =\= 0 -> 
                        MediaAvaliacoes is SomaAvali/QtdAvali,
                        geraStringServico(N,Categoria,Descricao,MediaAvaliacoes,Preco,NomeP,EmailP,StringServico),
                        listarServicosAux2(T,String,N,R,StringServico);

                        getAtributosServico(H,Categoria,Descricao,Preco,EmailP,NomeP),
                        geraStringServico(N,Categoria,Descricao,0.0,Preco,NomeP,EmailP,StringServico),
                        listarServicosAux2(T,String,N,R,StringServico).

listarServicosAux2(T,String,N,R,StringServico):-
    string_concat(String,StringServico,NovaString),
    N2 is N+1,
    listarServicosAux(T,NovaString,N2,R).


getAtributosServico(Lista,Categoria,Descricao,Preco,EmailP,NomeP):-
    nth0(0,Lista,Categoria),
    nth0(1,Lista,Descricao),
    nth0(2,Lista,Preco),
    nth0(3,Lista,EmailP),
    nth0(4,Lista,NomeP).

geraStringServico(N,Categoria,Descricao,MediaAvaliacoes,Preco,NomeP,EmailP,String):-
    formataDescricao(Descricao,NovaDescricao),
    format(atom(String),
        '\nNúmero: ~w\nCategoria: ~w\nDescrição: ~w\nAvaliação: ~1f ⭐\nPreço: R$ ~w\nProfissional: ~w\nEmail: ~w\n',
        [N,Categoria,NovaDescricao,MediaAvaliacoes,Preco,NomeP,EmailP]).

formataDescricao(Descricao,R):-
    formataDescricaoAux(Descricao,"",R).
    

formataDescricaoAux([],String,R):- R = String.
formataDescricaoAux([H|T],String,R):-
    string_concat(String,H,NovaString),
    string_concat(NovaString," ",NovaString2),
    formataDescricaoAux(T,NovaString2,R).


geraAtendimentoPendente(EmailC,NomeC,Lista,NovoServico):- geraAtendimentoPendenteAux(EmailC,NomeC,Lista,1,NovoServico).

geraAtendimentoPendenteAux(EmailC,NomeC,Lista,N,NovoServico):-
    getAtributosServico(Lista,Categoria,Descricao,Preco,EmailP,NomeP),
    format(atom(Servico),
        'atPendente(~w,~w,~w,~w,~w,~w,~w,~w).',
        [EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,N]),
    \+ main:atPendente(EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,N),
    NovoServico = Servico;
    N2 is N +1,
    geraAtendimentoPendenteAux(EmailC,NomeC,Lista,N2,NovoServico).


getCategorias(R):- getCategoriasAux([],R),!.

getCategoriasAux(Lista,R):-
    main:categoria(Categoria),

    \+ member(Categoria,Lista),
    adiciona(Categoria,Lista,Lista2),
    getCategoriasAux(Lista2,R);
    R = Lista.





getServicosCategoria(Categoria,R):- getServicosCategoriaAux(Categoria,[],R),!.

getServicosCategoriaAux(Categoria,Lista,R):-
    L = [],
    main:servico(Categoria,Descricao,Preco,EmailP,NomeP),
    adiciona(NomeP,L,L2),
    adiciona(EmailP,L2,L3),
    adiciona(Preco,L3,L4),
    adiciona(Descricao,L4,L5),
    adiciona(Categoria,L5,L6),

    \+ member(L6,Lista),
    adiciona(L6,Lista,Lista2),
    getServicosCategoriaAux(Categoria,Lista2,R);
    R = Lista.



getDoisMelhorAvaliados([X,Y|_],[X,Y]).
getDoisMelhorAvaliados([X|_],[X]).
getDoisMelhorAvaliados([],[]).



getAtPendentesProfissional(Email,R):- getAtPendentesProfissionalAux(Email,[],R),!.

getAtPendentesProfissionalAux(Email,Lista,R):-
    L = [],
    main:atPendente(EmailC,NomeC,Categoria,Descricao,Preco,Email,Nome,N),
    adiciona(N,L,L2),
    adiciona(Nome,L2,L3),
    adiciona(Email,L3,L4),
    adiciona(Preco,L4,L5),
    adiciona(Descricao,L5,L6),
    adiciona(Categoria,L6,L7),
    adiciona(NomeC,L7,L8),
    adiciona(EmailC,L8,L9),

    \+ member(L9,Lista),
    adiciona(L9,Lista,Lista2),
    getAtPendentesProfissionalAux(Email,Lista2,R);
    R = Lista.





listarAtPendentesProfissional(Lista,R):- listarAtPendentesProfissionalAux(Lista,"",1,R).

listarAtPendentesProfissionalAux([],String,_,R):- R = String,!.
listarAtPendentesProfissionalAux([H|T],String,N,R):-
    getAtributosAtPendente(H,EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,_),
    getAvaliacoes(Categoria,Descricao,Preco,EmailP,NomeP,AvaliacoesL),
    somaAvaliacoes(AvaliacoesL,SomaAvali),
    length(AvaliacoesL,QtdAvali),
    QtdAvali =\= 0 -> 
                        MediaAvaliacoes is SomaAvali/QtdAvali,
                        geraStringAtPendente(N,EmailC,NomeC,Categoria,Descricao,MediaAvaliacoes,Preco,StringAtPendente),
                        listarAtPendentesProfissionalAux2(T,String,N,R,StringAtPendente);

                        getAtributosAtPendente(H,EmailC,NomeC,Categoria,Descricao,Preco,_,_,_),
                        geraStringAtPendente(N,EmailC,NomeC,Categoria,Descricao,0.0,Preco,StringAtPendente),
                        listarAtPendentesProfissionalAux2(T,String,N,R,StringAtPendente).

listarAtPendentesProfissionalAux2(T,String,N,R,StringAtPendente):-
    string_concat(String,StringAtPendente,NovaString),
    N2 is N+1,
    listarAtPendentesProfissionalAux(T,NovaString,N2,R).




getAtributosAtPendente(Lista,EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,Numero):-
    nth0(0,Lista,EmailC),
    nth0(1,Lista,NomeC),
    nth0(2,Lista,Categoria),
    nth0(3,Lista,Descricao),
    nth0(4,Lista,Preco),
    nth0(5,Lista,EmailP),
    nth0(6,Lista,NomeP),
    nth0(7,Lista,Numero).


geraStringAtPendente(N,EmailC,NomeC,Categoria,Descricao,MediaAvaliacoes,Preco,String):-
    formataDescricao(Descricao,NovaDescricao),
    format(atom(String),
        '\nNúmero: ~w\nCategoria: ~w\nDescrição: ~w\nAvaliação: ~1f ⭐\nPreço: R$ ~w\nCliente: ~w\nEmail: ~w\n',
        [N,Categoria,NovaDescricao,MediaAvaliacoes,Preco,NomeC,EmailC]).



geraRetractAtPendente(AtPend,RetractAtPend):-
    getAtributosAtPendente(AtPend,EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,Numero),
    format(atom(RetractAtPend),
        '?- retract(atPendente(~w,~w,~w,~w,~w,~w,~w,~w)).',
        [EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,Numero]).




geraAtAceito(AtPend,AtAceito):- geraAtAceitoAux(AtPend,1,AtAceito).

geraAtAceitoAux(AtPend,N,AtAceito):-
    getAtributosAtPendente(AtPend,EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,_),
    format(atom(AtA),
        'atAceito(~w,~w,~w,~w,~w,~w,~w,~w).',
        [EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,N]),
    \+ main:atAceito(EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,N),
    AtAceito = AtA;
    N2 is N +1,
    geraAtAceitoAux(AtPend,N2,AtAceito).



geraAtRecusado(AtPend,AtRecusado):- geraAtRecusadoAux(AtPend,1,AtRecusado).

geraAtRecusadoAux(AtPend,N,AtRecusado):-
    getAtributosAtPendente(AtPend,EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,_),
    format(atom(AtR),
        'atRecusado(~w,~w,~w,~w,~w,~w,~w,~w).',
        [EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,N]),
    \+ main:atRecusado(EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,N),
    AtRecusado = AtR;
    N2 is N +1,
    geraAtRecusadoAux(AtPend,N2,AtRecusado).





getAtAceitosCliente(EmailC,R):- getAtAceitosClienteAux(EmailC,[],R).

getAtAceitosClienteAux(EmailC,Lista,R):-
    L = [],
    main:atAceito(EmailC,NomeC,Categoria,Descricao,Preco,Email,Nome,N),
    adiciona(N,L,L2),
    adiciona(Nome,L2,L3),
    adiciona(Email,L3,L4),
    adiciona(Preco,L4,L5),
    adiciona(Descricao,L5,L6),
    adiciona(Categoria,L6,L7),
    adiciona(NomeC,L7,L8),
    adiciona(EmailC,L8,L9),


    \+ member(L9,Lista),
    adiciona(L9,Lista,Lista2),
    writeln(Lista2),
    getAtAceitosClienteAux(EmailC,Lista2,R);
    R = Lista.




listarAtAceitosCliente(Lista,R):- listarAtAceitosClienteAux(Lista,"",1,R).

listarAtAceitosClienteAux([],String,_,R):- R = String,!.
listarAtAceitosClienteAux([H|T],String,N,R):-
    getAtributosAtAceito(H,_,_,Categoria,Descricao,Preco,EmailP,NomeP,_),
    getAvaliacoes(Categoria,Descricao,Preco,EmailP,NomeP,AvaliacoesL),
    somaAvaliacoes(AvaliacoesL,SomaAvali),
    length(AvaliacoesL,QtdAvali),
    QtdAvali =\= 0 -> 
                        MediaAvaliacoes is SomaAvali/QtdAvali,
                        geraStringAtAceito(N,EmailP,NomeP,Categoria,Descricao,MediaAvaliacoes,Preco,StringAtAceito),
                        listarAtAceitosClienteAux2(T,String,N,R,StringAtAceito);

                        getAtributosAtAceito(H,_,_,Categoria,Descricao,Preco,EmailP,NomeP,_),
                        geraStringAtAceito(N,EmailP,NomeP,Categoria,Descricao,0.0,Preco,StringAtAceito),
                        listarAtAceitosClienteAux2(T,String,N,R,StringAtAceito).

listarAtAceitosClienteAux2(T,String,N,R,StringAtAceito):-
    string_concat(String,StringAtAceito,NovaString),
    N2 is N+1,
    listarAtAceitosClienteAux(T,NovaString,N2,R).




geraStringAtAceito(N,EmailP,NomeP,Categoria,Descricao,MediaAvaliacoes,Preco,String):-
    formataDescricao(Descricao,NovaDescricao),
    format(atom(String),
        '\nNúmero: ~w\nCategoria: ~w\nDescrição: ~w\nAvaliação: ~1f ⭐\nPreço: R$ ~w\nProfissional: ~w\nEmail: ~w\n',
        [N,Categoria,NovaDescricao,MediaAvaliacoes,Preco,NomeP,EmailP]).


getAtributosAtAceito(Lista,EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,Numero):-
    nth0(0,Lista,EmailC),
    nth0(1,Lista,NomeC),
    nth0(2,Lista,Categoria),
    nth0(3,Lista,Descricao),
    nth0(4,Lista,Preco),
    nth0(5,Lista,EmailP),
    nth0(6,Lista,NomeP),
    nth0(7,Lista,Numero).




geraRetractAtAceito(AtAceito,RetractAtAceito):-
    getAtributosAtAceito(AtAceito,EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,Numero),
    format(atom(RetractAtAceito),
        '?- retract(atAceito(~w,~w,~w,~w,~w,~w,~w,~w)).',
        [EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,Numero]).



geraAtendimentoConcluitdo(AtAceit,Avaliacao,NovoAtConcluido):- geraAtendimentoConcluitdoAux(AtAceit,Avaliacao,1,NovoAtConcluido).

geraAtendimentoConcluitdoAux(AtAceit,Avaliacao,N,NovoAtConcluido):-
    getAtributosAtAceito(AtAceit,EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,_),
    format(atom(AtC),
        'atConcluido(~w,~w,~w,~w,~w,~w,~w,~w,~w).',
        [EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,Avaliacao,N]),
    \+ main:atConcluido(EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,Avaliacao,N),
    NovoAtConcluido = AtC;
    N2 is N +1,
    geraAtendimentoConcluitdoAux(AtAceit,Avaliacao,N2,NovoAtConcluido).




ordenaServicosAvaliacao([H|T],R) :-
    divisao(T,H,Esquerda,Direita),
    ordenaServicosAvaliacao(Esquerda,LadoEsquerdo),
    ordenaServicosAvaliacao(Direita,LadoDireito),
    append(LadoEsquerdo,[H|LadoDireito],R).
ordenaServicosAvaliacao([],[]).

divisao([H|T],Pivot,[H|LadoEsquerdo],LadoDireito) :-
    getAtributosServico(H,CategoriaH,DescricaoH,PrecoH,EmailPH,NomePH),
    getAvaliacoes(CategoriaH,DescricaoH,PrecoH,EmailPH,NomePH,AvaliacoesH),
    somaAvaliacoes(AvaliacoesH,SomaAvaliH),
    length(AvaliacoesH,QtdAvaliH),
    media(SomaAvaliH,QtdAvaliH,MediaH),

    getAtributosServico(Pivot,CategoriaP,DescricaoP,PrecoP,EmailPP,NomePP),
    getAvaliacoes(CategoriaP,DescricaoP,PrecoP,EmailPP,NomePP,AvaliacoesP),
    somaAvaliacoes(AvaliacoesP,SomaAvaliP),
    length(AvaliacoesP,QtdAvaliP),
    media(SomaAvaliP,QtdAvaliP,MediaP),

    MediaH > MediaP, divisao(T,Pivot,LadoEsquerdo,LadoDireito).


divisao([H|T],Pivot,LadoEsquerdo,[H|LadoDireito]) :-
    getAtributosServico(H,CategoriaH,DescricaoH,PrecoH,EmailPH,NomePH),
    getAvaliacoes(CategoriaH,DescricaoH,PrecoH,EmailPH,NomePH,AvaliacoesH),
    somaAvaliacoes(AvaliacoesH,SomaAvaliH),
    length(AvaliacoesH,QtdAvaliH),
    media(SomaAvaliH,QtdAvaliH,MediaH),

    getAtributosServico(Pivot,CategoriaP,DescricaoP,PrecoP,EmailPP,NomePP),
    getAvaliacoes(CategoriaP,DescricaoP,PrecoP,EmailPP,NomePP,AvaliacoesP),
    somaAvaliacoes(AvaliacoesP,SomaAvaliP),
    length(AvaliacoesP,QtdAvaliP),
    media(SomaAvaliP,QtdAvaliP,MediaP),

    MediaH =< MediaP, divisao(T,Pivot,LadoEsquerdo,LadoDireito). 
%>

divisao([],_,[],[]).

append([],L2,L2).
append([H|T],L2,[H|T2]) :- append(T,L2,T2).

media(_,0,0.0):- !.
media(SomaAvali,QtdAvali,R):-
    R is SomaAvali / QtdAvali.



getFaturamentoProfissional(EmailP,R):-
    getTodosServicosProfissional(EmailP,Servicos),
    getFaturamentoProfissionalAux(Servicos,[],Faturamentos),
    listaFaturamento(Faturamentos,R).



getFaturamentoProfissionalAux([],Lista,R):- R = Lista.
getFaturamentoProfissionalAux([H|T],Lista,R):-
    L = [],
    getFaturamentoProfissionalAux2(H,AtConcluidos),

    adiciona(AtConcluidos,L,L2),
    adiciona(H,L2,L3),

    \+ member(L3,Lista),
    adiciona(L3,Lista,Lista2),


    getFaturamentoProfissionalAux(T,Lista2,R).



getFaturamentoProfissionalAux2(Servico,R):- getFaturamentoProfissionalAux3(Servico,[],0,R),!.

getFaturamentoProfissionalAux3(Servico,Lista,Num,R):-
    getAtributosServico(Servico,Categoria,Descricao,Preco,EmailP,NomeP),

    L = [],
    main:atConcluido(EmailC,NomeC,Categoria,Descricao,Preco,EmailP,NomeP,Avaliacao,N),
   
    adiciona(N,L,L2),
    adiciona(Avaliacao,L2,L3),
    adiciona(NomeP,L3,L4),
    adiciona(EmailP,L4,L5),
    adiciona(Preco,L5,L6),
    adiciona(Descricao,L6,L7),
    adiciona(Categoria,L7,L8),
    adiciona(NomeC,L8,L9),
    adiciona(EmailC,L9,L10),




    \+ member(L10,Lista),
    adiciona(L10,Lista,Lista2),
    Num2 is Num +1, 
    getFaturamentoProfissionalAux3(Servico,Lista2,Num2,R);
    R = Num.





getTodosServicosProfissional(Email,R):- getTodosServicosProfissionalAux(Email,[],R),!.

getTodosServicosProfissionalAux(Email,Lista,R):-
    L = [],
    main:servico(Categoria,Descricao,Preco,Email,Nome),
    adiciona(Nome,L,L2),
    adiciona(Email,L2,L3),
    adiciona(Preco,L3,L4),
    adiciona(Descricao,L4,L5),
    adiciona(Categoria,L5,L6),

    \+ member(L6,Lista),
    adiciona(L6,Lista,Lista2),
    getTodosServicosProfissionalAux(Email,Lista2,R);
    R = Lista.


listaFaturamento(Lista,R):- listaFaturamentoAux(Lista,"",1,R).

listaFaturamentoAux([],String,_,R):- R = String,!.
listaFaturamentoAux([H|T],String,N,R):-
    nth0(0,H,Servico),
    nth0(1,H,QtdConclusoes),
    getAtributosServico(Servico,Categoria,Descricao,Preco,EmailP,NomeP),
    getAvaliacoes(Categoria,Descricao,Preco,EmailP,NomeP,AvaliacoesL),
    somaAvaliacoes(AvaliacoesL,SomaAvali),
    length(AvaliacoesL,QtdAvali),
    media(SomaAvali,QtdAvali,MediaAvaliacoes),
    Faturamento is Preco * QtdConclusoes,
    geraStringFaturamento(N,Categoria,Descricao,MediaAvaliacoes,Preco,Faturamento,StringAtAceito),
    listaFaturamentoAux2(T,String,N,R,StringAtAceito).

listaFaturamentoAux2(T,String,N,R,StringAtAceito):-
    string_concat(String,StringAtAceito,NovaString),
    N2 is N+1,
    listaFaturamentoAux(T,NovaString,N2,R).



geraStringFaturamento(N,Categoria,Descricao,MediaAvaliacoes,Preco,Faturamento,StringFaturamento):-
    formataDescricao(Descricao,NovaDescricao),
    format(atom(StringFaturamento),
        '\nNúmero: ~w\nCategoria: ~w\nDescrição: ~w\nAvaliação: ~1f ⭐\nPreço: R$ ~w\nFaturamento: R$ ~1f\n',
        [N,Categoria,NovaDescricao,MediaAvaliacoes,Preco,Faturamento]).



getServicosContratadosClientePendentes(Email,R):- getServicosContratadosClientePendentesAux(Email,[],R),!.

getServicosContratadosClientePendentesAux(Email,Lista,R):-
    L = [],
    main:atPendente(Email,_,Categoria,Descricao,Preco,Emailp,Nomep,N),
    adiciona(N,L,L2),
    adiciona(Nomep,L2,L3),
    adiciona(Emailp,L3,L4),
    adiciona(Preco,L4,L5),
    adiciona(Descricao,L5,L6),
    adiciona(Categoria,L6,L7),

    \+ member(L7,Lista),
    adiciona(L7,Lista,Lista2),
    getServicosContratadosClientePendentesAux(Email,Lista2,R);
    R = Lista.



getServicosContratadosClienteAceitos(Email,R):- getServicosContratadosClienteAceitosAux(Email,[],R),!.

getServicosContratadosClienteAceitosAux(Email,Lista,R):-
    L = [],
    main:atAceito(Email,_,Categoria,Descricao,Preco,Emailp,Nomep,N),
    adiciona(N,L,L2),
    adiciona(Nomep,L2,L3),
    adiciona(Emailp,L3,L4),
    adiciona(Preco,L4,L5),
    adiciona(Descricao,L5,L6),
    adiciona(Categoria,L6,L7),

    \+ member(L7,Lista),
    adiciona(L7,Lista,Lista2),
    getServicosContratadosClienteAceitosAux(Email,Lista2,R);
    R = Lista.



getServicosContratadosClienteRecusados(Email,R):- getServicosContratadosClienteRecusadosAux(Email,[],R),!.

getServicosContratadosClienteRecusadosAux(Email,Lista,R):-
    L = [],
    main:atRecusado(Email,_,Categoria,Descricao,Preco,Emailp,Nomep,N),
    adiciona(N,L,L2),
    adiciona(Nomep,L2,L3),
    adiciona(Emailp,L3,L4),
    adiciona(Preco,L4,L5),
    adiciona(Descricao,L5,L6),
    adiciona(Categoria,L6,L7),

    \+ member(L7,Lista),
    adiciona(L7,Lista,Lista2),
    getServicosContratadosClienteRecusadosAux(Email,Lista2,R);
    R = Lista.


listaAtNaoCloncluidoCliente(Lista,R):- listaAtNaoCloncluidoClienteAux(Lista,"",1,R).

listaAtNaoCloncluidoClienteAux([],String,_,R):- R = String,!.
listaAtNaoCloncluidoClienteAux([H|T],String,N,R):-

    getAtributosServico(H,Categoria,Descricao,Preco,EmailP,NomeP),

 
    getAvaliacoes(Categoria,Descricao,Preco,EmailP,NomeP,AvaliacoesL),
    somaAvaliacoes(AvaliacoesL,SomaAvali),
    length(AvaliacoesL,QtdAvali),
    media(SomaAvali,QtdAvali,MediaAvaliacoes),
    geraStringAtNaoConcluido(N,Categoria,Descricao,MediaAvaliacoes,Preco,EmailP,NomeP,StringNaoConcluido),
    listaAtNaoCloncluidoClienteAux2(T,String,N,R,StringNaoConcluido).

listaAtNaoCloncluidoClienteAux2(T,String,N,R,StringNaoConcluido):-
    string_concat(String,StringNaoConcluido,NovaString),
    N2 is N+1,
    listaAtNaoCloncluidoClienteAux(T,NovaString,N2,R).



geraStringAtNaoConcluido(N,Categoria,Descricao,MediaAvaliacoes,Preco,EmailP,NomeP,StringNaoConcluido):-
    formataDescricao(Descricao,NovaDescricao),
    format(atom(StringNaoConcluido),
        '\nNúmero: ~w\nCategoria: ~w\nDescrição: ~w\nAvaliação: ~1f ⭐\nPreço: R$ ~w\nProfissional: ~w\nEmail: ~w\n',
        [N,Categoria,NovaDescricao,MediaAvaliacoes,Preco,NomeP,EmailP]).





getServicosContratadosClienteConcluidos(Email,R):- getServicosContratadosClienteConcluidosAux(Email,[],R),!.

getServicosContratadosClienteConcluidosAux(Email,Lista,R):-
    L = [],
    main:atConcluido(Email,_,Categoria,Descricao,Preco,Emailp,Nomep,Avaliacao,N),
    adiciona(N,L,L2),
    adiciona(Avaliacao,L2,L3),
    adiciona(Nomep,L3,L4),
    adiciona(Emailp,L4,L5),
    adiciona(Preco,L5,L6),
    adiciona(Descricao,L6,L7),
    adiciona(Categoria,L7,L8),

    \+ member(L8,Lista),
    adiciona(L8,Lista,Lista2),
    getServicosContratadosClienteConcluidosAux(Email,Lista2,R);
    R = Lista.



listaAtCloncluidoCliente(Lista,R):- listaAtCloncluidoClienteAux(Lista,"",1,R).

listaAtCloncluidoClienteAux([],String,_,R):- R = String,!.
listaAtCloncluidoClienteAux([H|T],String,N,R):-

    getAtributosServico(H,Categoria,Descricao,Preco,EmailP,NomeP),
    nth0(5,H,Avaliacao),

    getAvaliacoes(Categoria,Descricao,Preco,EmailP,NomeP,AvaliacoesL),
    somaAvaliacoes(AvaliacoesL,SomaAvali),
    length(AvaliacoesL,QtdAvali),
    media(SomaAvali,QtdAvali,MediaAvaliacoes),
    geraStringAtConcluido(N,Categoria,Descricao,MediaAvaliacoes,Preco,EmailP,NomeP,Avaliacao,StringAtConcluido),
    listaAtCloncluidoClienteAux2(T,String,N,R,StringAtConcluido).

listaAtCloncluidoClienteAux2(T,String,N,R,StringAtConcluido):-
    string_concat(String,StringAtConcluido,NovaString),
    N2 is N+1,
    listaAtCloncluidoClienteAux(T,NovaString,N2,R).

geraStringAtConcluido(N,Categoria,Descricao,MediaAvaliacoes,Preco,EmailP,NomeP,Avaliacao,StringAtConcluido):-
    formataDescricao(Descricao,NovaDescricao),
    format(atom(StringAtConcluido),
        '\nNúmero: ~w\nCategoria: ~w\nDescrição: ~w\nAvaliação: ~1f ⭐\nPreço: R$ ~w\nProfissional: ~w\nEmail: ~w\nSua Avaliação foi: ~w ⭐\n',
        [N,Categoria,NovaDescricao,MediaAvaliacoes,Preco,NomeP,EmailP,Avaliacao]).