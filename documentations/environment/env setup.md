# Environment setup

Install anaconda and create environment 'gb3'.

## Autocomplete python script flags

Run

```bash
pip install argcomplete
activate-global-python-argcomplete --user
```

Add the following to ~/.bashrc

```bash
# -- argcomplete global helper (defines _python_argcomplete) --
if [ -f "$HOME/.local/etc/bash_completion.d/python-argcomplete.sh" ]; then
    . "$HOME/.local/etc/bash_completion.d/python-argcomplete.sh"
fi

# local registration for runner.py
eval "$(register-python-argcomplete3 runner.py)"
```
