# RVM's GPG key security signing mechanism requires gpg2 for key import / validation

class rvm::gpg {
  ensure_packages(['gnupg2'])
}
