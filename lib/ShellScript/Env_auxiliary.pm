package ShellScript::Env_auxiliary;

use strict;

$ShellScript::Env_auxiliary::utok = 0;
$ShellScript::Env_auxiliary::sh_export = 0;
$ShellScript::Env_auxiliary::csh_upcase_path = 0;

sub new {
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;

  $self->{'variable'} = shift;
  $self->postfix(@_);

  return $self;
}

sub utok {
  my $self = shift;
  my $set = shift;

  if (!defined $self->{'utok'}) {
    return $ShellScript::Env_auxiliary::utok;
  } else {
    return $self->{'utok'};
  }
}

sub postfix {
  my $self = shift;

  push @{$self->{'path'}}, @_;
  return $self;
}

sub set {
  my $self = shift;

  undef @{$self->{'path'}};
  return $self->postfix(@_);
}



sub sh {
  my $self = shift;

  my $output = "$self->{variable}=";
  if ($self->utok()) {
    $output .= '`utok ';
  }

  for (@{$self->{'path'}}) {
    $output .= "$_:";
  }

  if ($self->utok()) {
    $output =~ s/:$/\`\n/;
  } else {
    $output =~ s/:$/\n/;
  }

  if ($ShellScript::Env_auxiliary::sh_export) {
    $output .= "export $self->{variable}\n";
  }

  return $output;
}

sub csh {
  my $self = shift;

  my $output = 'set';

  if (!$ShellScript::Env_auxiliary::csh_upcase_path &&
      ($self->{'variable'} eq 'PATH')) {
    $output .= ' path = (';
    if ($self->utok()) {
      $output .= '`utok -d \  ';
    }
    for (@{$self->{'path'}}) {
      if ($_ eq '$PATH') {
	$output .= '$path ';
      } else {
        $output .= "$_ ";
      }
    }
    if ($self->utok()) {
      $output =~ s/ $/\`\)\n/;
    } else {
      $output =~ s/ $/\)\n/;
    }
    
  } else {
    $output .= "env $self->{variable} ";
    if ($self->utok()) {
      $output .= '`utok ';
    }
    for (@{$self->{'path'}}) {
      $output .= "$_:";
    }
    if ($self->utok()) {
      $output =~ s/:$/\`\n/;
    } else {
      $output =~ s/:$/\n/;
    }
  }

  return $output;
}

return 1;

