// SPDX-License-Identifier: GPL-3.0

// Se pretende resolver el sistema de votación para candidatos en un país en el que se 
// permita registrar votantes, candidatos y votos
// El sistema debe ser capaz de validar que:
    // - el candidato cumple con los requisitos necesarios para ser registrado
    // - el votante cumple con los requisitos necesarios
    // - que el votante pueda votar solamente una vez
    
pragma solidity >=0.7.0 <0.9.0;
// import ÷"hardhat/console.sol";
import "hardhat/console.sol";

contract Votaciones{

    uint32 totalDeVotos;
    uint fechaHoraLimiteDeVotacion = 1665285283;
    address propietarioDelContrato;

    constructor() public{
       propietarioDelContrato = msg.sender;
    }

    struct Votante{
        string nombre;
        bool votoRegistrado;
        bool puedeVotar;
    }
    
    struct Candidato{
        uint id;
        string nombre;
        uint32 votos;
    }

    mapping(address => Votante) listaDeVotantes;
    mapping(address => Candidato) listaDeCandidatos;

    function registrarVotante (string memory nombre, string memory nacionalidad, uint edad) validarDerechoDeVoto(nacionalidad, edad) public {
        listaDeVotantes[msg.sender].puedeVotar = true;
        listaDeVotantes[msg.sender].votoRegistrado = false;
        listaDeVotantes[msg.sender].nombre=nombre;
    }

    function registrarCandidatos(string memory nombre, string memory nacionalidad, uint edad, uint id) public{
        require(keccak256(abi.encodePacked((nacionalidad)))==keccak256(abi.encodePacked(('Mexicana'))), 'No puedes ser registrado como candidato, la nacionalidad requerida es Mexicana');
        require(edad>=35, 'No puedes ser registrado como candidato, la edad minima es 35');
        listaDeCandidatos[msg.sender].id = id;
        listaDeCandidatos[msg.sender].nombre=nombre;
    }


    function votar (address addressCandidato) limiteDeVotacion public {
        require(listaDeVotantes[msg.sender].puedeVotar == true, 'No registrado o no puedes votar');
        require(!listaDeVotantes[msg.sender].votoRegistrado, 'No puedes votar + de una ocasion');
        listaDeVotantes[msg.sender].votoRegistrado = true;
        listaDeCandidatos[addressCandidato].votos = listaDeCandidatos[addressCandidato].votos +1;
        totalDeVotos+=1;
    }

    function obtenerGanador() public returns(uint _votos){
        return listaDeCandidatos[0xbDA5747bFD65F08deb54cb465eB87D40e51B197E].votos;

    }

    modifier limiteDeVotacion{ // Validar que el usuario está votando dentro del horario impuesto
        uint timestamp = block.timestamp;
        fechaHoraLimiteDeVotacion = timestamp; // cambiar esta linea para permitir el voto
        require(timestamp<=fechaHoraLimiteDeVotacion, 'Las votaciones se han cerrado');
        _;
    }

    modifier validarDerechoDeVoto ( string memory nacionalidad, uint edad){ // Propietario valida que cumple con los requisitos para votar
        require(msg.sender == propietarioDelContrato, 'No puedes otorgar derecho a votar');
        require(keccak256(abi.encodePacked((nacionalidad)))==keccak256(abi.encodePacked(('Mexicana'))), 'No puedes ser registrado como votante, la nacionalidad requerida es Mexicana');
        require(edad>=18, 'No puedes votar, eres menor de edad');
        _;

    }
}