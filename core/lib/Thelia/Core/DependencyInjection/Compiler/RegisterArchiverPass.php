<?php
/*************************************************************************************/
/*      This file is part of the Thelia package.                                     */
/*                                                                                   */
/*      Copyright (c) OpenStudio                                                     */
/*      email : dev@thelia.net                                                       */
/*      web : http://www.thelia.net                                                  */
/*                                                                                   */
/*      For the full copyright and license information, please view the LICENSE.txt  */
/*      file that was distributed with this source code.                             */
/*************************************************************************************/

namespace Thelia\Core\DependencyInjection\Compiler;

use Symfony\Component\DependencyInjection\Compiler\CompilerPassInterface;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Exception\InvalidArgumentException;
use Symfony\Component\DependencyInjection\Reference;

/**
 * Class RegisterArchiverPass
 * @author Benjamin Perche <bperche@openstudio.fr>
 * @author Jérôme Billiras <jbilliras@openstudio.fr>
 */
class RegisterArchiverPass implements CompilerPassInterface
{
    /**
     * @var string Archiver manager service ID
     */
    const MANAGER_SERVICE_ID = 'thelia.archiver.manager';

    /**
     * @var string Archiver tag name
     */
    const ARCHIVER_SERVICE_TAG = 'thelia.archiver';

    public function process(ContainerBuilder $container)
    {
        try {
            $manager = $container->getDefinition(self::MANAGER_SERVICE_ID);
        } catch (InvalidArgumentException $e) {
            return;
        }

        foreach (array_keys($container->findTaggedServiceIds(self::ARCHIVER_SERVICE_TAG)) as $serviceId) {
            $manager->addMethodCall(
                'add',
                [
                    new Reference($serviceId)
                ]
            );
        }
    }
}
