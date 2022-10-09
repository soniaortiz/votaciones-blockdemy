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
    address[] public direccionDeCandidatos;
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

    function registrarVotante(string memory nombre, string memory nacionalidad, uint edad, address direccionVotante) validarDerechoDeVoto(nacionalidad, edad) public {
        listaDeVotantes[direccionVotante].puedeVotar = true;
        listaDeVotantes[direccionVotante].votoRegistrado = false;
        listaDeVotantes[direccionVotante].nombre=nombre;
    }

    function registrarCandidatos(string memory nombre, string memory nacionalidad, uint edad, address direccionCandidato) public{
        require(keccak256(abi.encodePacked((nacionalidad)))==keccak256(abi.encodePacked(('Mexicana'))), 'No puedes ser registrado como candidato, la nacionalidad requerida es Mexicana');
        require(edad>=35, 'No puedes ser registrado como candidato, la edad minima es 35');
        listaDeCandidatos[direccionCandidato].nombre=nombre;
        direccionDeCandidatos.push(direccionCandidato);
    }


    function votar (address addressCandidato) limiteDeVotacion public {
        require(listaDeVotantes[msg.sender].puedeVotar == true, 'No registrado o no puedes votar');
        require(!listaDeVotantes[msg.sender].votoRegistrado, 'No puedes votar + de una ocasion');
        listaDeVotantes[msg.sender].votoRegistrado = true;
        listaDeCandidatos[addressCandidato].votos = listaDeCandidatos[addressCandidato].votos +1;
        totalDeVotos+=1;
    }

    function obtenerGanador() public returns(Candidato memory _candidato){
        uint mayorNumeroDeVotos = listaDeCandidatos[direccionDeCandidatos[0]].votos;
        Candidato memory candidatoGanador = listaDeCandidatos[direccionDeCandidatos[0]];

        for(uint i=0; i<direccionDeCandidatos.length; i++){
            if(listaDeCandidatos[direccionDeCandidatos[i]].votos>mayorNumeroDeVotos){
                candidatoGanador = listaDeCandidatos[direccionDeCandidatos[i]];
            }
        }
        return candidatoGanador;

    }

    modifier limiteDeVotacion{ // Validar que el usuario está votando dentro del horario impuesto
        uint timestamp = block.timestamp;
        fechaHoraLimiteDeVotacion = timestamp; // comentar esta linea para bloquear/cerrar votaciones
        require(timestamp<=fechaHoraLimiteDeVotacion, 'Las votaciones se han cerrado');
        _;
    }

    modifier validarDerechoDeVoto ( string memory nacionalidad, uint edad){ // Propietario valida que cumple con los requisitos para votar
        require(msg.sender == propietarioDelContrato, 'No puedes otorgar derecho a votar');
        require(keccak256(abi.encodePacked((nacionalidad)))==keccak256(abi.encodePacked(('Mexicana'))), 
            'No puedes ser registrado como votante, la nacionalidad requerida es Mexicana');
        require(edad>=18, 'No puedes votar, eres menor de edad');
        _;

    }
}