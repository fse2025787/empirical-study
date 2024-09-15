// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;   // à cause de la structure retournée par `getBetInfo()`

/**
 *Submitted for verification at Etherscan.io on 2022-11-20
*/

/******************************************
    Personal Bookmaker
    
    Systèmes pour effectuer un pari entre
    amis dans le cadre privé.
    
    Copyright © 2020-2022 Personal-Bookmaker.net
    
******************************************/

pragma solidity ^0.7.0;             // on cible solidity 0.7.x



/*** le contrat de pari, acheté par l’organisateur ***/

contract PrivateBet
{
/* constantes */

    string public constant  VERSION             = "4.1.1";
    uint public constant    NB_MAX_PARTICIPANT  = 30;       // bridage à 30 participants max
    
    // Message signé par l'appelant de `getBetInfo()` : hashMessage("PrivateBet")
    bytes32 private constant AUTH_MSG = 0x257cc31861cde10af4851394d4ac648b8c6ed14355eff69f4ce64eba4b8e24cf;
    uint    private constant MICRO_ETH = 10**12; // 1E+18 * 1E-6 wei. 1µ eth <=> 0.1 centime d'€ @1000 €/eth


/* défintions des type personnalisés */

    struct Participant
    {
        bool      knownUser;    // participant autorisés à parier
        uint8     betId;        // proposition pariée
        uint256   totalBet;     // montant totale misée sur une ou plusieurs propositions
    }

    enum State
    {
        Open,           // les paris sont ouverts (--> ajout de participant; pari possibles si date <= limite et montant < limite)
        Canceled,       // le pari est annulé (--> remboursement autorisé)
        Closed_Winner,  // le pari est terminé et nous avons au moins un gagnant (--> les vainqueurs peuvent retirer leur gain)
        Closed_NoWinner // le pari est terminé mais personne n'a gagné (--> remboursement de tous les participants autorisé)
    }

    // donnés retournées par `getBetInfo()`
    struct BetInfo {
        address   owner;             // adresse de l'organisateur du pari
        uint8     outcomeId;         // index du résultat final du pari (donne la proposition gagnante). Valide uniquement dans les états Closed_XXX
        uint8     nbParticipant;     // nombre actuel de participant
        uint8     nbPossibilities;   // nombre de résultats possibles
        State     state;             // état du pari
        uint32    externDescriptionId;//identifiant 32bits de description externe du pari (lien avec la BDD du site web)
        uint32    betDeadlineTime;   // date limite pour parier (date UNIX / EPOC)
        uint32    minimumStake_micro;// mise minimale d'un participant en µEther
        uint32    totalMaxStake_micro;//mise maximale totale pour un participant en µEther
        uint256[] betAmountByProp;   // montant total misé par résultat possible du pari
    }

    struct Bet {
        mapping(address => Participant) participants; // BDD (via map) des info par participants
        address   owner;             // adresse de l'organisateur du pari
        uint32    betDeadlineTime;   // date limite pour parier (date UNIX / EPOC)
        uint32    externDescriptionId;//identifiant 32bits de description externe du pari (lien avec la BDD du site web)
        State     state;             // état du pari
        uint8     outcomeId;         // index du résultat final du pari (donne la proposition gagnante). Valide uniquement dans les états Closed_XXX
        uint8     nbParticipant;     // nombre actuel de participant
        uint8     nbPossibilities;   // nombre de résultats possibles
        uint256[] betAmountByProp;   // montant total misé par résultat possible du pari
        uint256   winningsAmount;    // montant total des gain. Positionné uniquement quand la proposition gagante est fournie.
        address   guestPubKeyAdr;    // pseudo clé publique du pari pour authentifier un invité
        uint32    minimumStake_micro;// mise minimale d'un participant en µEther
        uint32    totalMaxStake_micro;//mise maximale totale pour un participant en µEther
    }


/* données publiques */

    bool public m_createBetDisabled; // empêche la création de nouveaux paris (cf. `disableBetCreation()`)   


/* événements */

    // un nouveau pari est créé
    event NewBetCreated(uint indexed betId, address indexed user);
    // un nouveau participant est inscrit 
    event NewParticiant(uint indexed betId, address indexed user);
    // une nouvelle mise est enregistrée
    event NewBet(uint indexed betId, address indexed user, uint256 stake, uint outcomeId);
    // fin du pari, le résultat a été donné
    event BetClosed(uint indexed betId, bool hasWinner);
    // le pari est annulé
    event BetCanceled(uint indexed betId);
    // un remboursement à l'appelant est effectué
    event Transfer(uint indexed betId, address indexed user, uint256 amount);
    // un don vient d'être effectué
    event NewDonation(uint indexed betId, address indexed user, uint256 amount);


/* fonction publiques */

    
    
    constructor() {
        m_owner = msg.sender;
    }

    
    
    
    
    
    
    
    
    
    function createBet(uint32 _externDescriptionId, uint _nbPossibilities, uint _betDeadlineTime,
                uint32 _minimumStake_micro, uint32 _totalMaxStake_micro, address _guestPubKeyAdr, bool _ownerParticipate)
    public {
        require(!m_createBetDisabled, "CreateBetDisabled");  // la création de pris est actuellement suspendue
        require(_nbPossibilities >= 2, "TooFewPossibility");   // Il faut au moins 2 possibilités
        require(_nbPossibilities < 2**8, "TooManyPossibilities");// 255 possibilités max
        require(_betDeadlineTime > block.timestamp, "DeadlineAlreadyPassed");   // Date limite déjà passée
        require(_totalMaxStake_micro >= _minimumStake_micro, "InvalidTotalMaxStake");// Mise maximale doit être au moins celle minimale

        uint nextId = m_bets.length;
        
        Bet storage bt = m_bets.push();
        bt.owner               = msg.sender;
        bt.betDeadlineTime     = uint32(_betDeadlineTime);
        bt.externDescriptionId = _externDescriptionId;
        //bt.state             = State.Open;
        bt.nbPossibilities     = uint8(_nbPossibilities);
        bt.betAmountByProp     = new uint256[](_nbPossibilities);
        bt.guestPubKeyAdr      = _guestPubKeyAdr;
        bt.minimumStake_micro  = _minimumStake_micro;
        bt.totalMaxStake_micro = _totalMaxStake_micro;
        
        emit NewBetCreated(nextId, msg.sender);
        
        // on inscrit l'organisateur ?
        if (_ownerParticipate) {
            bt.participants[msg.sender].knownUser = true;

            // prise en compte du participant
            bt.nbParticipant++;
            emit NewParticiant(nextId, msg.sender);
        }
    }

    
    function getNbBetCreated() public view returns(uint)  {
        return m_bets.length;
    }

    
    
    
    
    
    
    
    function getBetInfo(uint _id, bytes32 _rSign, bytes32 _sSign, uint8 _vSign) public view
    returns(BetInfo memory inf_)  {
        // only known user (créateur du contract, organisateur, invité ou participant)
        require(msg.sender == m_owner || msg.sender == m_bets[_id].owner ||
                msg.sender == m_bets[_id].guestPubKeyAdr || // `&& m_bets[_id].guestPubKeyAdr != address(0)` innutile grâce à "InvalidSignature"
                m_bets[_id].participants[msg.sender].knownUser, "OnlyKnownUser");

        // vérif signature du msg pour garantir l'authenticité de l'appelant
        address signer = ecrecover(AUTH_MSG, _vSign, _rSign, _sSign);
        require(signer != address(0), "InvalidSignature"); // signature invalide (bug)
        require(signer == msg.sender, "WrongSigner");  // signataire incorrecte (bug ou tentative d'usurpation d'identité)
        
        Bet storage bt = m_bets[_id];
        inf_.owner               = bt.owner;
        inf_.outcomeId           = bt.outcomeId;
        inf_.nbParticipant       = bt.nbParticipant;
        inf_.nbPossibilities     = bt.nbPossibilities;
        inf_.state               = bt.state;
        inf_.externDescriptionId = bt.externDescriptionId;
        inf_.betDeadlineTime     = bt.betDeadlineTime;
        inf_.minimumStake_micro  = bt.minimumStake_micro;
        inf_.totalMaxStake_micro = bt.totalMaxStake_micro;
        inf_.betAmountByProp     = bt.betAmountByProp;
    }

    
    ///         permi et uniquement lorsque le pari est dans l'état ouvert.
    
    ///         ce qui est attendu si la limite max est atteinte ou en cas de doublons avec des participants déjà inscrits.
    
    
    function addParticipants(uint _id, address[] memory _adrParticipants) public onlyOrganizer(_id) {
        Bet storage bt = m_bets[_id];
        require(bt.state == State.Open, "ImproperState");    // Etat 'ouvert' requis
        
        // parcours du tableau reçu dans la limite du nbr de participant max autorisés
        for (uint newUsers; newUsers < _adrParticipants.length && bt.nbParticipant < NB_MAX_PARTICIPANT; newUsers++) {
            address p = _adrParticipants[newUsers];
            // on ajoute uniquement le participant s'il est valide et n'est pas déjà connu
            if (p != address(0) && !bt.participants[p].knownUser) {
                bt.participants[p].knownUser = true;

                // prise en compte du participant
                bt.nbParticipant++;
                emit NewParticiant(_id, p);
            }
        }
    }

    
    ///         et uniquement lorsque le pari est dans l'état ouvert.
    
    ///         L'organisateur du pari transmet à ses invités la clé privée correspondant à l'adresse publique du pari.
    ///         L'invité va signer un message comportant son adresse pour rendre la signature unique à chaque
    ///         paricipant et donc non réutilisable par un petit malin voulant s'inscrire au même pari et qui utiliserait
    ///         Etherscan pour récupéer une ancienne signature.
    
    
    ///             par l'organisateur du pari.
    
    
    function participate(uint _id, bytes32 _rSign, bytes32 _sSign, uint8 _vSign) public {
        Bet storage bt = m_bets[_id];
        require(bt.state == State.Open, "ImproperState");    // Etat 'ouvert' requis
        
        // vérif signature de web3.eth.accounts.sign({participant})
        bytes32 msgHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n20", msg.sender));
        address signer = ecrecover(msgHash, _vSign, _rSign, _sSign);
        require(signer != address(0), "InvalidSignature"); // signature invalide (bug)
        require(signer == bt.guestPubKeyAdr, "WrongSigner");  // signataire incorrecte (bug, invitation modifiée/désactivée ou tentative de fraude)
        
        // peut-on encore en ajouter un ?
        if (bt.nbParticipant < NB_MAX_PARTICIPANT) {
            address p = msg.sender;
            
            // on ajoute uniquement le participant s'il n'est pas déjà connu
            if (!bt.participants[p].knownUser) {
                bt.participants[p].knownUser = true;

                // prise en compte du participant
                bt.nbParticipant++;
                emit NewParticiant(_id, p);
            }
        }
    }

    
    
    
    
    function isParticipant(uint _id) public view returns(bool)  {
        return m_bets[_id].participants[msg.sender].knownUser;
    }

    
    ///         correspondante est compromise ou pour suspendre les invitations.
    
    
    function setGuestPubKeyAdr(uint _id, address _pubKeyAdr) public onlyOrganizer(_id) {
        m_bets[_id].guestPubKeyAdr = _pubKeyAdr;
    }

    
    
    
    function cancelBet(uint _id) public onlyOrganizer(_id) {
        Bet storage bt = m_bets[_id];
        require(bt.state == State.Open, "ImproperState"); // Etat 'ouvert' requis

        bt.state = State.Canceled;
        
        emit BetCanceled(_id);
    }

    
    ///         d'au moins la mise minimale la première fois. Possible uniquement lorsque le pari est dans l'état ouvert
    ///         et que la date limite de pari n'est pas passée.
    
    ///         si le plafond de mise maximale du participant est atteint.
    
    
    function bet(uint _id, uint _outcomeId) public payable onlyParticipant(_id) {
        Bet storage bt = m_bets[_id];
        require(bt.state == State.Open, "ImproperState");        // Etat 'ouvert' requis
        require(block.timestamp <= bt.betDeadlineTime, "DeadlineExpired");   // Date limite dépassée
        require(_outcomeId < bt.nbPossibilities, "OutOfBoundIndex");// index hors bornes
        
        Participant storage p = bt.participants[msg.sender];
        uint256 totalBet = p.totalBet; // copie mémoire pour optimiser

        // 1ère mise ?
        if (totalBet == 0) {
            // première fois : on vérifie qu'on a mis au moins le minimum 
            require(msg.value >= bt.minimumStake_micro * MICRO_ETH, "InsufficientStake"); // QUITTE sur err : mise insuffisante
            // mémorisation de la proposition
            p.betId = uint8(_outcomeId);
        } else {
            // on ne peut surenchérire que sur la même proposition
            require(_outcomeId == p.betId, "MultiChoiceNotAllowed"); // QUITTE sur err : choix multiples non permis
        }
        
        uint256 betAmount;
        
        // plafond non atteint ?
        uint256 totalMaxStake = bt.totalMaxStake_micro * MICRO_ETH;
        if (totalBet < totalMaxStake) {
            // limitation de la somme misée par le plafond
            betAmount = (totalBet + msg.value > totalMaxStake) ? totalMaxStake - totalBet : msg.value;
            // prise en compte du pari
            bt.betAmountByProp[_outcomeId] += betAmount;
            emit NewBet(_id, msg.sender, betAmount, _outcomeId);
            // mise à jour de la mise du joueur
            p.totalBet = totalBet + betAmount;
        }
        
        // remboursement du trop perçu le cas échéant
        if (msg.value > betAmount)
            msg.sender.transfer(msg.value - betAmount);
    }
    
    
    ///         et de miser en même temps sur une proposition le montant transmis. Celui-ci doit être d'au moins la
    ///         mise minimale. Possible uniquement lorsque le pari est dans l'état ouvert et que la date limite de
    ///         pari n'est pas passée.
    
    ///         somme nouvellement pariée qui peut être inférieur au montant transmis si le plafond de mise maximale
    ///         du participant est atteint.
    ///         L'organisateur du pari transmet à ses invités la clé privée correspondant à l'adresse publique du pari.
    ///         L'invité va signer un message comportant son adresse pour rendre la signature unique à chaque
    ///         paricipant et donc non réutilisable par un petit malin voulant s'inscrire au même pari et qui utiliserait
    ///         Etherscan pour récupéer une ancienne signature.
    
    
    ///             par l'organisateur du pari.
    
    
    
    function participateAndBet(uint _id, bytes32 _rSign, bytes32 _sSign, uint8 _vSign, uint _outcomeId)
    public payable {
        Bet storage bt = m_bets[_id];
        require(bt.state == State.Open, "ImproperState");    // Etat 'ouvert' requis
        require(block.timestamp <= bt.betDeadlineTime, "DeadlineExpired");   // Date limite dépassée
        require(_outcomeId < bt.nbPossibilities, "OutOfBoundIndex");// index hors bornes
        require(msg.value >= bt.minimumStake_micro * MICRO_ETH, "InsufficientStake"); // mise insuffisante
        
        // vérif signature de web3.eth.accounts.sign({participant})
        bytes32 msgHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n20", msg.sender));
        address signer = ecrecover(msgHash, _vSign, _rSign, _sSign);
        require(signer != address(0), "InvalidSignature"); // signature invalide (bug)
        require(signer == bt.guestPubKeyAdr, "WrongSigner");  // signataire incorrecte (bug, invitation modifiée/désactivée ou tentative de fraude)
        
        uint256 betAmount;
        
        // peut-on encore en ajouter un ?
        if (bt.nbParticipant < NB_MAX_PARTICIPANT) {
            Participant storage p = bt.participants[msg.sender];
            
            // on ajoute uniquement le participant s'il n'est pas déjà connu
            if (!p.knownUser) {
                // prise en compte du participant
                bt.nbParticipant++;
                emit NewParticiant(_id, msg.sender);

                // limitation de la somme misée par le plafond
                uint256 totalMaxStake = bt.totalMaxStake_micro * MICRO_ETH;
                betAmount = (msg.value > totalMaxStake) ? totalMaxStake : msg.value;
                // prise en compte du pari
                bt.betAmountByProp[_outcomeId] += betAmount;
                emit NewBet(_id, msg.sender, betAmount, _outcomeId);
                // maj info du Participant
                p.knownUser = true;
                p.betId = uint8(_outcomeId);
                p.totalBet = betAmount;
            }
        }
        
        // remboursement du trop perçu le cas échéant
        if (msg.value > betAmount)
            msg.sender.transfer(msg.value - betAmount);
    }
    
    
    
    
    
    
    
    
    
    
    function createBetAndBet(uint32 _externDescriptionId, uint _nbPossibilities, uint _betDeadlineTime,
                uint32 _minimumStake_micro, uint32 _totalMaxStake_micro, address _guestPubKeyAdr, uint _outcomeId)
    public payable {
        require(!m_createBetDisabled, "CreateBetDisabled");  // la création de pris est actuellement suspendue
        require(_nbPossibilities >= 2, "TooFewPossibility");   // Il faut au moins 2 possibilités
        require(_nbPossibilities < 2**8, "TooManyPossibilities");// 255 possibilités max
        require(_betDeadlineTime > block.timestamp, "DeadlineAlreadyPassed");   // Date limite déjà passée
        require(_totalMaxStake_micro >= _minimumStake_micro, "InvalidTotalMaxStake");// Mise maximale doit être au moins celle minimale
        require(_outcomeId < _nbPossibilities, "OutOfBoundIndex");// index hors bornes
        require(msg.value >= _minimumStake_micro * MICRO_ETH, "InsufficientStake"); // mise insuffisante
        
        uint nextId = m_bets.length;
        
        Bet storage bt = m_bets.push();
        bt.owner               = msg.sender;
        bt.betDeadlineTime     = uint32(_betDeadlineTime);
        bt.externDescriptionId = _externDescriptionId;
        //bt.state             = State.Open;
        bt.nbPossibilities     = uint8(_nbPossibilities);
        bt.betAmountByProp     = new uint256[](_nbPossibilities);
        bt.guestPubKeyAdr      = _guestPubKeyAdr;
        bt.minimumStake_micro  = _minimumStake_micro;
        bt.totalMaxStake_micro = _totalMaxStake_micro;
        
        emit NewBetCreated(nextId, msg.sender);
        
        Participant storage p = bt.participants[msg.sender];

        // prise en compte du participant
        bt.nbParticipant++;
        emit NewParticiant(nextId, msg.sender);
        
        // limitation de la somme misée par le plafond
        uint256 totalMaxStake = _totalMaxStake_micro * MICRO_ETH;
        uint256 betAmount = (msg.value > totalMaxStake) ? totalMaxStake : msg.value;
        // prise en compte du pari
        bt.betAmountByProp[_outcomeId] = betAmount;
        emit NewBet(nextId, msg.sender, betAmount, _outcomeId);
        // maj info du Participant
        p.knownUser = true;
        p.betId = uint8(_outcomeId);
        p.totalBet = betAmount;
        
        // remboursement du trop perçu le cas échéant
        if (msg.value > betAmount)
            msg.sender.transfer(msg.value - betAmount);
    }

    
    ///         l'état ouvert et que la date limite de pari est passée.
    
    
    
    function setBetOutcome(uint _id, uint _outcomeId) public onlyOrganizer(_id) {
        Bet storage bt = m_bets[_id];
        require(bt.state == State.Open, "ImproperState");        // Etat 'ouvert' requis
        require(block.timestamp > bt.betDeadlineTime, "DeadlineNotPassed");  // Date limite pas encore échue
        require(_outcomeId < bt.nbPossibilities, "OutOfBoundIndex");//index hors bornes

        // avons nous un gagnant ?
        bool hasWinner = (bt.betAmountByProp[_outcomeId] > 0);
        if (hasWinner) {
            // calcul du pactole des gagants
            uint256 s;
            uint256[] storage tbl = bt.betAmountByProp; // accès tableau en registre pour optimiser
            uint length = tbl.length;                   // taille en cache pour optimiser
            for(uint i; i < length; i++)
                s += tbl[i];

            // mémo des gains pour calculer les parts de chacun des gagants
            bt.winningsAmount = s;

            bt.state = State.Closed_Winner;
        } else {
            bt.state = State.Closed_NoWinner;
        }
        
        // mémo résultat
        bt.outcomeId = uint8(_outcomeId);
        // retourne si on a un gagnant
        emit BetClosed(_id, hasWinner);
    }

    
    ///         ou annulé. Possible uniquement lorsque le pari est dans l'état 'annulé' ou 'Fermé sans gagnant'.
    
    
    
    function reimbursement(uint _id) public onlyParticipant(_id) returns(uint256 amount_) {
        Bet storage bt = m_bets[_id];
        require(bt.state == State.Canceled || bt.state == State.Closed_NoWinner, "ImproperState"); // Etat incompatible
        
        Participant storage p = bt.participants[msg.sender];
        // qq chose à rembourser ?
        if (p.totalBet > 0)
        {
            amount_ = p.totalBet;
            p.totalBet = 0; // on RAZ l'état avant le transfert pour éviter un hack par réentrance

            emit Transfer(_id, msg.sender, amount_);
            msg.sender.transfer(amount_);
        }
    }

    
    ///         'Fermé avec gagnant'.
    
    
    
    function withdrawWinnings(uint _id) public onlyParticipant(_id) returns(uint256 amount_) {
        Bet storage bt = m_bets[_id];
        require(bt.state == State.Closed_Winner, "ImproperState"); // Etat 'fermé avec gagnant' requis
        
        Participant storage p = bt.participants[msg.sender];
        
        // a-t-il gagné ?
        if (p.betId == bt.outcomeId) {
            // calcul du gain commun au prorata de la mise sur la proposition gagante
            amount_ = (bt.winningsAmount * p.totalBet) / bt.betAmountByProp[bt.outcomeId];
        
            // qq chose à retirer ?
            if (amount_ > 0) {
                p.totalBet = 0; // on RAZ l'état avant le transfert pour éviter un hack par réentrance
    
                emit Transfer(_id, msg.sender, amount_);
                msg.sender.transfer(amount_);
            }
        }
    }

    
    
    
    function donate(uint _id) public payable {
        emit NewDonation(_id, msg.sender, msg.value);
        m_owner.transfer(msg.value);
    }

    
    
    ///         mal avec le contrat.
    
    function disableBetCreation(bool _disable) public onlyOwner {
        m_createBetDisabled = _disable;
    }


/* modifieurs */

    // s'assure que c'est le créateur du contrat qui est l'appelant    
    modifier onlyOwner {
        require(msg.sender == m_owner, "OnlyOwner"); // Cmd réservée au créateur du contrat
        _;
    }

    // s'assure que c'est l'organisateur qui est l'appelant    
    modifier onlyOrganizer(uint _id) {
        require(msg.sender == m_bets[_id].owner, "OnlyOrganizer"); // Cmd réservée à l'organisateur
        _;
    }

    // s'assure que c'est un participant qui est l'appelant    
    modifier onlyParticipant(uint _id) {
        require(m_bets[_id].participants[msg.sender].knownUser, "OnlyParticipant"); // Cmd réservée à un participant inscrit
        _;
    }


/* données privées */

    Bet[] private           m_bets;     // tableau des donnés des paris
    address payable private m_owner;    // adresse du créateur du contrat, 'payable' pour le tranfère des dons


/* fonction internes */

}