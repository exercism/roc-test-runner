app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.14.0/dC5ceT962N_4jmoyoffVdphJ_4GlW3YMhAPyGPr-nU0.tar.br",
    unicode: "https://github.com/roc-lang/unicode/releases/download/0.1.1/-FQDoegpSfMS-a7B0noOnZQs3-A2aq9RSOR5VVLMePg.tar.br",
}

import pf.Task exposing [Task]

expect Bool.true

main =
    Task.ok {}
