/*
 ░░▄███▄███▄
░░█████████
░░▒▀█████▀░
░░▒░░▀█▀
░░▒░░█░
░░▒░█
░░░█
░░█░░░░███████
░██░░░██▓▓███▓██▒
██░░░█▓▓▓▓▓▓▓█▓████
██░░██▓▓▓(◐)▓█▓█▓█
███▓▓▓█▓▓▓▓▓█▓█▓▓▓▓█
▀██▓▓█░██▓▓▓▓██▓▓▓▓▓█
░▀██▀░░█▓▓▓▓▓▓▓▓▓▓▓▓▓█
░░░░▒░░░█▓▓▓▓▓█▓▓▓▓▓▓█
░░░░▒░░░█▓▓▓▓█▓█▓▓▓▓▓█
░▒░░▒░░░█▓▓▓█▓▓▓█▓▓▓▓█
░▒░░▒░░░█▓▓▓█░░░█▓▓▓█
░▒░░▒░░██▓██░░░██▓▓██
████████████████████████
█▄─▄███─▄▄─█▄─█─▄█▄─▄▄─█
██─██▀█─██─██─█─███─▄█▀█
▀▄▄▄▄▄▀▄▄▄▄▀▀▄▄▄▀▀▄▄▄▄▄▀

Welcome to LOVE contract!
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Token is IBEP20 {
    string public name = "LOVE YOU"; // Nazwa tokena
    string public symbol = "LOV"; // Skrót symbolu tokena
    uint8 public decimals = 18; // Liczba miejsc po przecinku

    uint256 private _totalSupply = 1000000000000000000000000000000;

    mapping(address => uint256) private _balances; // Salda kont
    mapping(address => mapping(address => uint256)) private _allowances; // Uprawnienia do wydawania tokenów

    constructor() {
        _balances[msg.sender] = _totalSupply; // Przydzielenie całego salda początkowego do adresu deployera kontraktu
        emit Transfer(address(0), msg.sender, _totalSupply); // Wywołanie zdarzenia Transfer, aby odnotować utworzenie całego salda na koncie deployera
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply; // Zwraca całkowitą liczbę tokenów w obiegu
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account]; // Zwraca saldo konta
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount); // Wywołanie wewnętrznej funkcji _transfer do realizacji transferu tokenów
        return true; // Zwraca wartość true w przypadku powodzenia transferu
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender]; // Zwraca liczbę tokenów, które właściciel konta upoważnił do wydania przez danego wydawcę
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount); // Wywołanie wewnętrznej funkcji _approve do ustawienia upoważnienia do wydania tokenów
        return true; // Zwraca wartość true w przypadku powodzenia ustawienia upoważnienia
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount); // Wywołanie wewnętrznej funkcji _transfer do realizacji transferu tokenów
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;   
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "BEP20: transfer from the zero address"); // Sprawdzenie, czy adres nadawcy nie jest zerowy
        require(recipient != address(0), "BEP20: transfer to the zero address"); // Sprawdzenie, czy adres odbiorcy nie jest zerowy
        require(amount > 0, "BEP20: transfer amount must be greater than zero"); // Sprawdzenie, czy wartość transferu jest większa niż zero
        require(_balances[sender] >= amount, "BEP20: transfer amount exceeds balance"); // Sprawdzenie, czy nadawca ma wystarczające saldo

        _balances[sender] -= amount; // Odjęcie ilości tokenów od salda nadawcy
        _balances[recipient] += amount; // Dodanie ilości tokenów do salda odbiorcy
        emit Transfer(sender, recipient, amount); // Wywołanie zdarzenia Transfer w celu odnotowania transferu tokenów
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address"); // Sprawdzenie, czy właściciel konta nie jest zerowym adresem
        require(spender != address(0), "BEP20: approve to the zero address"); // Sprawdzenie, czy adres uprawnionego nie jest zerowy

        _allowances[owner][spender] = amount; // Ustawienie upoważnienia do wydania tokenów
        emit Approval(owner, spender, amount); // Wywołanie zdarzenia Approval w celu odnotowania ustawienia upoważnienia
    }

    // Funkcja spalania tokenów
    function burn(uint256 amount) external {
        require(amount > 0, "BEP20: burn amount must be greater than zero"); // Sprawdzenie, czy wartość spalania jest większa niż zero
        require(_balances[msg.sender] >= amount, "BEP20: burn amount exceeds balance"); // Sprawdzenie, czy nadawca ma wystarczające saldo

        _balances[msg.sender] -= amount; // Odjęcie ilości tokenów od salda nadawcy
        _totalSupply -= amount; // Odjęcie ilości tokenów od całkowitej podaży
        emit Transfer(msg.sender, address(0), amount); // Wywołanie zdarzenia Transfer, aby odnotować spalenie tokenów
    }

    // Funkcja spalania tokenów z upoważnienia
    function burnFrom(address account, uint256 amount) external {
        require(amount > 0, "BEP20: burn amount must be greater than zero"); // Sprawdzenie, czy wartość spalania jest większa niż zero
        require(_balances[account] >= amount, "BEP20: burn amount exceeds balance"); // Sprawdzenie, czy konto ma wystarczające saldo

        uint256 currentAllowance = _allowances[account][msg.sender];
        require(currentAllowance >= amount, "BEP20: burn amount exceeds allowance"); // Sprawdzenie, czy upoważnienie jest wystarczające

        _balances[account] -= amount; // Odjęcie ilości tokenów od salda konta
        _totalSupply -= amount; // Odjęcie ilości tokenów od całkowitej podaży
        _approve(account, msg.sender, currentAllowance - amount); // Zmniejszenie upoważnienia o spalane tokeny
        emit Transfer(account, address(0), amount); // Wywołanie zdarzenia Transfer, aby odnotować spalenie tokenów
    }
}