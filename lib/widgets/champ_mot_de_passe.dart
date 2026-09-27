import 'package:flutter/material.dart';

/// Password field with a show/hide toggle. Validation is left to the caller.
class ChampMotDePasse extends StatefulWidget {
  final TextEditingController? controller;
  final String libelle;
  final String? indice;
  final String? aide;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final bool actif;

  const ChampMotDePasse({
    super.key,
    this.controller,
    this.libelle = 'Mot de passe',
    this.indice,
    this.aide,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.autofillHints,
    this.actif = true,
  });

  @override
  State<ChampMotDePasse> createState() => _ChampMotDePasseState();
}

class _ChampMotDePasseState extends State<ChampMotDePasse> {
  bool _masque = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _masque,
      enabled: widget.actif,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      keyboardType: TextInputType.visiblePassword,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: widget.libelle,
        hintText: widget.indice,
        helperText: widget.aide,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _masque
              ? 'Afficher le mot de passe'
              : 'Masquer le mot de passe',
          icon: Icon(
            _masque ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: widget.actif
              ? () => setState(() => _masque = !_masque)
              : null,
        ),
      ),
    );
  }
}
