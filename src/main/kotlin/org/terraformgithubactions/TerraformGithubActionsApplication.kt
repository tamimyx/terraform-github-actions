package org.terraformgithubactions

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class TerraformGithubActionsApplication

fun main(args: Array<String>) {
    runApplication<TerraformGithubActionsApplication>(*args)
}
